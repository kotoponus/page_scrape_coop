#!/usr/bin/perl

use strict;
use diagnostics;

# Lack of better knowledge, I use the following modules.
use Mojo::DOM;
use File::Slurp;

use feature 'say';

############################################
# Configuration
############################################
# Shows where the data HTML files sit
my $directory = "data";
# how the result file (CSV file) should be called.
my $result_file = "result";

my $stacker;
my $summary;
my @files;

# Just in case we just want to feed a few files rather than scroll through all the files in a directory in $directory.
if (@ARGV) {
	@files = @ARGV;
} else {
	@files = get_files($directory);
}

# Main routine
foreach my $f (@files) {
	my $file_cont = read_file($directory."/".$f);
	my $produce = parse_dom($file_cont);
	my $nr_of_lines = $produce =~ tr/\n//;
	$summary .= "$f : $nr_of_lines transactions\n";
	$stacker .= $produce;
}

# result to display
print "========= RESULT =========\n";
if ($summary) {
	print $summary;
	write_file($result_file,$stacker);
} else {
	print "No files were processed.\n";
}
print "==========================\n";


##############################################
# Functions
##############################################

# to list all the files
sub get_files {
	my $directory = $_[0];
	opendir(DIR,$directory) or die "couldn't open directory \"$directory\": $!\n";
	my @files = readdir DIR;
	closedir DIR;
	# HACK: this should be more robust files
	return grep /\.html$/, @files;
}

# Parse "dom" object to comma delimited string
sub parse_dom {
	my $dom = Mojo::DOM->new($_[0]);
	# There is no id specification on tags...  :(  Rather ugly, but there.
	my $yay = $dom->at('td.paddingTopBottom15>table.summaryTable');

	my $stacker;
	$yay->find("tr")->each(sub{
		my $row = shift;
		my $tmp = $row->children->map(sub {
			my $s = $_->text;
			#  HACK: Diagnostics gives me a warning.  I should see if I can rectify.
			#        Also I think there bount to be more elegant ways to go about editing out the invalid chars.
			$s !~ s/[^[:ascii:]]//g;
			return $s;
	      	})->join(',')."\n";
		# Below is straigth foward version of above without the removal of odd characters.
		# my $tmp = $row->children->map("text")->join(',')."\n";
		# Below gets rid of aggregate lines, headers, infotmational lines
		if ($tmp !~ m/(\*Last Statement\*|Date,Transaction,Money in,Money out|BROUGHT FORWARD)/) {
			$stacker .= $tmp;
		}
	});
	return $stacker;
}

