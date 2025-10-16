#!/usr/bin/env perl

use strict;
use warnings;

# alles gut

sub format_file_size {
	my $size = shift;
	my @units = qw(B KB MB GB TB);

	for my $unit (@units) {
		if ($size < 1024) {
			if ($unit eq 'B') {
				return sprintf "%.0f %s", $size, $unit;
			} else {
				return sprintf "%.1f %s", $size, $unit;
			}
		}
		$size /= 1024;
	}
	return sprintf "%.1f TB", $size;
}

sub gcd {
	my ($a, $b) = @_;
	while ($b) {
		($a, $b) = ($b, $a % $b);
	}
	return $a;
}

sub get_aspect_ratio {
	my ($width, $height) = @_;
	return unless $width && $height;

	my $divisor = gcd($width, $height);
	return sprintf "%d:%d", $width / $divisor, $height / $divisor;
}

sub get_webp_dimensions {
	my $file_path = shift;

	open my $fh, '<:raw', $file_path or return;
	read $fh, my $data, 50;
	close $fh;

	return unless length($data) >= 30 &&
	substr($data, 0, 4) eq 'RIFF' &&
	substr($data, 8, 4) eq 'WEBP';

	# Look for first chunk after WEBP header
	my $pos = 12;
	my $chunk_type = substr($data, $pos, 4);

	if ($chunk_type eq 'VP8 ' && length($data) >= $pos + 18) {
		# Simple VP8: dimensions at offset 14,16 from chunk start
		return map { unpack('v', substr($data, $pos + 14 + $_ * 2, 2)) & 0x3fff } (0, 1);
	}
	elsif ($chunk_type eq 'VP8L' && length($data) >= $pos + 13) {
		# VP8L: packed dimensions after signature byte
		my $dim = unpack('V', substr($data, $pos + 9, 4));
		return (($dim & 0x3fff) + 1, (($dim >> 14) & 0x3fff) + 1);
	}
	elsif ($chunk_type eq 'VP8X' && length($data) >= $pos + 18) {
		# VP8X: 24-bit dimensions at offset 4,7 in chunk
		my $w = unpack('V', substr($data, $pos + 12, 3) . "\0") + 1;
		my $h = unpack('V', substr($data, $pos + 15, 3) . "\0") + 1;
		return ($w, $h);
	}

	return;
}

sub get_image_info {
	my $file_path = shift;

	my $file_size = -s $file_path;
	my ($width, $height) = get_webp_dimensions($file_path);
	my $aspect_ratio = get_aspect_ratio($width, $height) if $width && $height;

	return ($width, $height, $file_size, $aspect_ratio);
}

sub create_html {
	my ($title, $body, $back_link) = @_;

	my $back = $back_link ?
	'<div class="back-link"><a href="index.html">← Back to directories</a></div>' : '';

	return <<"EOF";
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>$title</title>
	<style>
	body { text-align: center; font-family: sans-serif; }
	h1 { margin: 40px 0; }
	p { margin: 15px 0; }
	a { text-decoration: none; font-size: 1.1em; }
	a:hover { text-decoration: underline; }
	figure { margin: 20px 0; }
	figure.hidden { display: none; }
	figcaption { margin-top: 5px; font-size: 0.9em; }
	figcaption small { color: #666; font-size: 0.8em; }
	img { max-width: 90%; height: auto; }
	.back-link { margin: 20px 0; }
	.filter-box { margin: 20px auto; max-width: 400px; }
	.filter-box input {
		padding: 10px;
		font-size: 1em;
		width: 100%;
		box-sizing: border-box;
		border: 2px solid #ccc;
		border-radius: 4px;
	}
	.filter-box input:focus {
		outline: none;
		border-color: #4CAF50;
	}
	</style>
</head>
<body>
	$back
	$body
</body>
</html>
EOF
}

sub scan_directories {
	my $base_dir = shift || "docs";

	opendir my $dh, $base_dir or die "Cannot open directory $base_dir: $!";
	my @directories;

	for my $entry (readdir $dh) {
		next if $entry =~ /^\.\.?$/;  # Skip . and ..
		my $dir_path = "$base_dir/$entry";
		next unless -d $dir_path;

		opendir my $sub_dh, $dir_path or next;
		my $webp_count = grep { /\.webp$/i } readdir $sub_dh;
		closedir $sub_dh;

		push @directories, [$entry, $webp_count] if $webp_count;
	}
	closedir $dh;

	return sort { $a->[0] cmp $b->[0] } @directories;
}

sub generate_main_index {
	my $base_dir = shift || "docs";
	my @directories = scan_directories($base_dir);

	unless (@directories) {
		print "No .webp files found in $base_dir\n";
		return;
	}

	my $links = join "\n\t",
	map { qq(<p><a href="$_->[0].html">$_->[0]/</a> ($_->[1] images)</p>) }
	@directories;

	my $html = create_html("WebP Image Directories", "<h1>WebP Image Directories</h1>\n\t$links");

	open my $fh, '>', "$base_dir/index.html" or die "Cannot write index.html: $!";
	print $fh $html;
	close $fh;

	printf "Generated index with %d directories\n", scalar @directories;
}

sub generate_dir_page {
	my $dir_path = shift;
	my $dir_name = ($dir_path =~ m|([^/]+)/?$|)[0];  # basename equivalent

	opendir my $dh, $dir_path or return;
	my @webp_files = grep { /\.webp$/i } readdir $dh;
	closedir $dh;
	return unless @webp_files;

	# Sort by modification time (newest first)
	# @webp_files = sort {
	# 	(stat("$dir_path/$b"))[9] <=> (stat("$dir_path/$a"))[9]
	# } @webp_files;

	# Sort alphabetically
	# @webp_files = sort @webp_files;
	# Sort reverse alphabetically
	@webp_files = sort { $b cmp $a } @webp_files;

	my @figures;
	my $total = scalar @webp_files;
	for my $i (0 .. $#webp_files) {
		my $file = $webp_files[$i];
		my ($width, $height, $file_size, $aspect_ratio) = get_image_info("$dir_path/$file");

		my @info;
		push @info, "${width}×${height}" if $width && $height;
		push @info, $aspect_ratio if $aspect_ratio;
		push @info, format_file_size($file_size);

		my $index = sprintf "[%d/%d]", $i + 1, $total;  # numbering
		my $caption = "$file $index<br><small>" . join(' • ', @info) . "</small>";
		push @figures, qq(<figure><img src="$dir_name/$file" loading="lazy"><figcaption>$caption</figcaption></figure>);
	}

	my $filter_box = '<div class="filter-box"><input type="text" id="filter" placeholder="Filter images (e.g., CG020)"></div>';
	my $script = <<'SCRIPT';
<script>
const filter = document.getElementById('filter');
const figures = document.querySelectorAll('figure');

filter.addEventListener('input', e => {
	const val = e.target.value.toLowerCase();
	figures.forEach(fig => {
		const src = fig.querySelector('img').src;
		fig.classList.toggle('hidden', val && !src.toLowerCase().includes(val));
	});
});
</script>
SCRIPT

	my $html = create_html("WebP Images - $dir_name",
		"<h1>$dir_name</h1>\n\t$filter_box\n\t" . join("\n\t", @figures) . "\n\n\t$script", 1);

	my ($parent_dir) = ($dir_path =~ m|^(.*)/[^/]+/?$|);  # dirname equivalent
	my $output_file = "$parent_dir/$dir_name.html";
	open my $fh, '>', $output_file or die "Cannot write $output_file: $!";
	print $fh $html;
	close $fh;

	printf "Generated %s.html with %d images\n", $dir_name, scalar @webp_files;
}

sub clean_html_files {
	my $base_dir = shift;
	for my $file (glob("$base_dir/*.html")) {
		unlink $file or warn "Could not delete $file: $!";
	}
}

sub main {
	my $base_dir = "docs";

	# Delete old HTML files first (using glob)
	clean_html_files($base_dir);

	generate_main_index($base_dir);

	# Process each directory that has WebP files
	my @directories = scan_directories($base_dir);
	generate_dir_page("$base_dir/$_->[0]") for @directories;
}

# Run main
main();
