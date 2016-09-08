#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use GraphCreator;


my $generatedFile = GraphCreator::createHtmlPageFromLogFile('t/debug.log');
ok ($generatedFile);


my $logfile = 't/sample-log-file.txt';
my $genFile = GraphCreator::createHtmlPageFromLogFile($logfile);
ok ($genFile);
open(F, $genFile);
{
    local $/;
    $/ = undef;
    my @content = <F>;
    ok (@content);
    ok (scalar(@content) > 0);
}

done_testing();

