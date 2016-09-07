#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Test::Deep;

use DataFromLogFile;


my $file = 't/debug.log';
my $lines = DataFromLogFile::extractRelevantLines($file);
ok (defined $lines);
ok (ref($lines) eq 'ARRAY');
ok (scalar(@$lines) > 0);


my $line = '[Tue Sep  6 11:35:16 2016][debug2] pid 1724 memory at beginning of _runTask() Collect : 88760';
my $memoryData = 88760;
my $lineData = DataFromLogFile::extractDataInLine($line);
my $lineDataExpected = [
    'Tue Sep  6 11:35:16 2016',
    '1724',
    'beginning Collect',
    $memoryData
];
Test::Deep::cmp_deeply(
    $lineData,
    $lineDataExpected,
    'testing data extracting from a line'
);
my $extractedMemoryData = DataFromLogFile::extractGraphDataInLine($line);
ok ($extractedMemoryData eq $memoryData);

my $data = DataFromLogFile::extractDataFromRelevantLines($file);
ok (defined $data);
ok (scalar(@$data) > 0);
my $dataFirstListExpected = [
    'Tue Sep  6 09:39:21 2016',
        '1724',
        'beginning Deploy',
        77528
];
Test::Deep::cmp_deeply(
    $data->[0],
    $dataFirstListExpected,
    'test of first list in data'
);

my $graphData = DataFromLogFile::extractGraphDataFromRelevantLines($file);
ok ($graphData->[0] eq $dataFirstListExpected->[3]);
ok (scalar(@$graphData) == scalar(@$data));

done_testing();

