#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

use Getopt::Long;

use GraphCreator;
use Cwd;
use File::Copy;
use File::Remove;

my $logfiles = [];

GetOptions(
    'logfile=s' => $logfiles
);

exit(1) if scalar(@$logfiles) == 0;

my $dir = cwd;

my $createdFiles = [];
for my $logfile (@$logfiles) {
    my $fileName = $logfile;
    $fileName =~ s/\//-_-/g;
    $fileName .= '-tmp';
    File::Copy::copy($logfile, $fileName);
    my $genFile = GraphCreator::createHtmlPageFromLogFile($fileName);
    push @$createdFiles, $genFile if $genFile;
    File::Remove::remove($fileName);
}

print 'created ' . scalar(@$createdFiles) . ' html graphs : ';
print "\n";
print join "\n", @$createdFiles;
print "\n";
