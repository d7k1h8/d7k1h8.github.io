#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;

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

	open my $fh, '<:raw', $file_path or return (undef, undef);

	# Read enough bytes for WebP header analysis
	my $data;
	read $fh, $data, 50;
	close $fh;

	return (undef, undef) if length($data) < 30;

	# Check WebP signature
	return (undef, undef) unless substr($data, 0, 4) eq 'RIFF' && substr($data, 8, 4) eq 'WEBP';

	my $pos = 12;
	while ($pos < length($data) - 8) {
		my $chunk_type = substr($data, $pos, 4);
		last if $pos + 8 > length($data);

		my $chunk_size = unpack('V', substr($data, $pos + 4, 4));

		if ($chunk_type eq 'VP8 ') {
			# Simple VP8 format
			if ($pos + 16 < length($data)) {
				my $frame_data = substr($data, $pos + 8);
				if (length($frame_data) >= 10) {
					my $width = unpack('v', substr($frame_data, 6, 2)) & 0x3fff;
					my $height = unpack('v', substr($frame_data, 8, 2)) & 0x3fff;
					return ($width, $height);
				}
			}
			last;
		}
		elsif ($chunk_type eq 'VP8L') {
			# Lossless VP8L format
			if ($pos + 13 < length($data)) {
				my $lossless_data = substr($data, $pos + 8);
				if (length($lossless_data) >= 5) {
					my $dim_data = unpack('V', substr($lossless_data, 1, 4));
					my $width = ($dim_data & 0x3fff) + 1;
					my $height = (($dim_data >> 14) & 0x3fff) + 1;
					return ($width, $height);
				}
			}
			last;
		}
		elsif ($chunk_type eq 'VP8X') {
			# Extended format
			if ($pos + 18 < length($data)) {
				my $vp8x_data = substr($data, $pos + 8);
				if (length($vp8x_data) >= 10) {
					# Width and height are 24-bit little-endian + 1
					my $width_bytes = substr($vp8x_data, 4, 3) . "\x00";
					my $height_bytes = substr($vp8x_data, 7, 3) . "\x00";
					my $width = unpack('V', $width_bytes) + 1;
					my $height = unpack('V', $height_bytes) + 1;
					return ($width, $height);
				}
			}
			last;
		}

		$pos += 8 + (($chunk_size + 1) >> 1) << 1;  # Align to even boundary
	}

	return (undef, undef);
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
	figcaption { margin-top: 5px; font-size: 0.9em; }
	figcaption small { color: #666; font-size: 0.8em; }
	img { max-width: 90%; height: auto; }
	.back-link { margin: 20px 0; }
	</style>
</head>
<body>
	$back
	$body
</body>
</html>
EOF
}

sub generate_main_index {
	my $base_dir = shift || "docs";

	opendir my $dh, $base_dir or die "Cannot open directory $base_dir: $!";
	my @entries = readdir $dh;
	closedir $dh;

	my @directories;

	for my $entry (@entries) {
		next if $entry eq '.' || $entry eq '..';
		my $dir_path = "$base_dir/$entry";
		next unless -d $dir_path;

		# Count WebP files in directory
		opendir my $sub_dh, $dir_path or next;
		my @files = grep { /\.webp$/i } readdir $sub_dh;
		closedir $sub_dh;

		if (@files) {
			push @directories, [$entry, scalar @files];
		}
	}

	unless (@directories) {
		print "No .webp files found in $base_dir\n";
		return;
	}

	@directories = sort { $a->[0] cmp $b->[0] } @directories;

	my $links = join "\n\t",
	map { qq(<p><a href="$_->[0].html">$_->[0]/</a> ($_->[1] images)</p>) }
	@directories;

	my $body = "<h1>WebP Image Directories</h1>\n\t$links";
	my $html = create_html("WebP Image Directories", $body, 0);

	my $output_file = File::Spec->catfile($base_dir, "index.html");
	open my $out_fh, '>', $output_file or die "Cannot write $output_file: $!";
	print $out_fh $html;
	close $out_fh;

	printf "Generated index with %d directories\n", scalar @directories;
}

sub generate_dir_page {
	my $dir_path = shift;

	opendir my $dh, $dir_path or return;
	my @webp_files = sort grep { /\.webp$/i } readdir $dh;
	closedir $dh;

	return unless @webp_files;

	my @figures;
	my $dir_name = basename($dir_path);

	for my $file (@webp_files) {
		my $file_path = File::Spec->catfile($dir_path, $file);
		my ($width, $height, $file_size, $aspect_ratio) = get_image_info($file_path);

		my @info;
		push @info, "${width}×${height}" if $width && $height;
		push @info, $aspect_ratio if $aspect_ratio;
		push @info, format_file_size($file_size);

		my $info_str = join ' • ', @info;
		my $caption = "$file<br><small>$info_str</small>";

		push @figures, qq(<figure><img src="$dir_name/$file"><figcaption>$caption</figcaption></figure>);
	}

	my $body = "<h1>$dir_name</h1>\n\t" . join("\n\t", @figures);
	my $html = create_html("WebP Images - $dir_name", $body, 1);

	my $parent_dir = dirname($dir_path);
	my $output_file = File::Spec->catfile($parent_dir, "$dir_name.html");

	open my $out_fh, '>', $output_file or die "Cannot write $output_file: $!";
	print $out_fh $html;
	close $out_fh;

	printf "Generated %s.html with %d images\n", $dir_name, scalar @webp_files;
}

sub main {
	my $base_dir = "docs";

	generate_main_index($base_dir);

	opendir my $dh, $base_dir or die "Cannot open directory $base_dir: $!";
	my @entries = readdir $dh;
	closedir $dh;

	for my $entry (@entries) {
		next if $entry eq '.' || $entry eq '..';
		my $dir_path = File::Spec->catdir($base_dir, $entry);
		next unless -d $dir_path;

		# Check if directory has WebP files
		opendir my $sub_dh, $dir_path or next;
		my @webp_files = grep { /\.webp$/i } readdir $sub_dh;
		closedir $sub_dh;

		if (@webp_files) {
			generate_dir_page($dir_path);
		}
	}
}

# Run main
main();
