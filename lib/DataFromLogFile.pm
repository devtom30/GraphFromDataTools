package DataFromLogFile;
use strict;
use warnings FATAL => 'all';


sub extractRelevantLines {
    my ($file) = @_;

    my $lines = [];
    open(F, $file) or return undef;
    while (my $line = <F>) {
        if ($line =~ /pid \d+ memory at/) {
            push @$lines, $line;
        }
    }

    return $lines;
}

sub extractDataInLine {
    my ($line) = @_;

    my $list;
    if ($line =~ /^\[([^\]]+)\].* pid (\d+) memory at (\w+) of _runTask\(\) (\w+) : (\d+)\r?$/) {
        $list = [
            $1,
            $2,
            $3 . ' ' . $4,
            $5
        ];
    } else {
#        print 'line not matching regex';
#        print "\n";
#        print $line . "\n";
        print $! . "\n";
    }

    return $list;
}

sub extractDataFromRelevantLines {
    my ($file) = @_;

    my $data = [];
    open(F, $file) or return undef;
    while (my $line = <F>) {
        if ($line =~ /pid \d+ memory at/) {
            chomp $line;
            push @$data, extractDataInLine($line);
        }
    }

    return $data;
}

sub extractGraphDataInLine {
    my ($line) = @_;

    my $data;
    if ($line =~ /^\[[^\]]+\].* pid \d+ memory at \w+ of _runTask\(\) \w+ : (\d+)\r?$/) {
        $data = $1;
    }

    return $data;
}

sub extractGraphDataFromRelevantLines {
    my ($file) = @_;

    my $data = [];
    open(F, $file) or return undef;
    while (my $line = <F>) {
        if ($line =~ /pid \d+ memory at/) {
            chomp $line;
            push @$data, extractGraphDataInLine($line);
        }
    }

    return $data;
}

1;
