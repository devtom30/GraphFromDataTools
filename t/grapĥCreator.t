#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use GraphCreator;


my $generatedFile = GraphCreator::createHtmlPageFromLogFile('t/debug.log');
ok ($generatedFile);
done_testing();

