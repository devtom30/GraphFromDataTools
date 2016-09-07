#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';


my $fh;
open($fh, '>', 'testwrite.txt') or die "can't open file for write";
print $fh 'Alorrrrrrs' . "\n";
print $fh, "et c'est la virgule alors ????" . "\n";
