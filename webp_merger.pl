#!/usr/bin/env perl
use strict;
use warnings;

# Check arguments
die "Usage: $0 [DIR]\n" unless @ARGV == 1;

my ($script_dir) = $0 =~ m{^(.*)/};
$script_dir ||= '.';
my $image_dir = "$script_dir/docs/$ARGV[0]";

die "Directory '$image_dir' does not exist\n" unless -d $image_dir;

# Find all .webp files in specified directory
my @files = sort glob("$image_dir/*.webp");
die 'No .webp files found' unless @files;

print 'Found ' . @files . " .webp files\n";

# Calculate grid dimensions (try to make it roughly square)
my $cols = int(sqrt(@files) + 0.5) || 1;

print "Creating grid with $cols columns\n";

# Build ImageMagick command
my @cmd = ('montage');

# Add each file with its label
foreach my $file (@files) {
	my ($basename) = $file =~ m{([^/]+)$};
	push @cmd, '-label', $basename, $file;
}

# Montage options
push @cmd, (
	'-tile', "${cols}x",
	'-geometry', '832x1216+10+10',
	'-background', 'black',
	'-font', '/usr/share/fonts/TTF/DejaVuSans.ttf',
	'-pointsize', '20',
	'output_grid.webp'
);

# Execute command
print 'Running: ' . join(' ', @cmd) . "\n";
exec(@cmd) or die "Failed to execute montage: $!";
