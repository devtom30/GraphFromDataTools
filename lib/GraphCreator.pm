package GraphCreator;
use strict;
use warnings FATAL => 'all';

use DataFromLogFile;


sub createHtmlPageFromData {
    my ($data, $generatedFile) = @_;

    my $templateFile = 'resources/index.html';
    open(F, $templateFile) or die "can't open TEMPLATE file " . $templateFile . ' : ' . $! . "\n";
    open(O, ">" . $generatedFile) or die "can't open GENERATED file " . $generatedFile . ' : ' . $! . "\n";;

    while (my $line = <F>) {
        if ($line =~ /^\s*<DATAHERE>\s*$/) {
            print 'injecting values in html page' . "\n";
            my $i = 0;
            for my $value (@$data) {
                print O '[' . $i++ . ', ' . $value . '],' . "\n";
                print $i . ' ';
            }
            print "\n";
        } else {
            print O $line;
        }
    }

    return 1;
}

sub createHtmlPageFromLogFile {
    my $logfile = shift;

    my $data = DataFromLogFile::extractGraphDataFromRelevantLines($logfile);
    print 'extracted ' . (scalar(@$data)) . ' values from ' . $logfile . "\n";
    $logfile =~ s/\//-_-/g;
    my $generatedFile = time . '_generatedFromFile_' . $logfile . '.html';
    if (createHtmlPageFromData($data, $generatedFile)) {
        return $generatedFile;
    } else {
        return undef;
    }
}

1;