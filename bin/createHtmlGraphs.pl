#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use Getopt::Long;

use GraphCreator;
use Cwd;

my $logfiles = [];

GetOptions(
    'logfile=s' => $logfiles
);

exit(1) if scalar(@$logfiles) == 0;

my $dir = cwd;

my $createdFiles = [];
for my $logfile (@$logfiles) {
    my $genFile = GraphCreator::createHtmlPageFromLogFile($logfile);
    push @$createdFiles, $genFile if $genFile;
}

print 'created ' . scalar(@$createdFiles) . ' html graphs : ';
print "\n";
print join "\n", @$createdFiles;
print "\n";
