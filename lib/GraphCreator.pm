package GraphCreator;
use strict;
use warnings FATAL => 'all';

use DataFromLogFile;


sub createHtmlPageFromData {
    my ($data, $generatedFile) = @_;

    my $templateFile = 'resources/index.html';
    my $readFh;
    my $writeFh;
    open($readFh, $templateFile) or die "can't open TEMPLATE file " . $templateFile . ' : ' . $! . "\n";
    open($writeFh, ">" . $generatedFile) or die "can't open GENERATED file " . $generatedFile . ' : ' . $! . "\n";;

    while (my $line = <$readFh>) {
        if ($line =~ /^\s*<DATAHERE>\s*$/) {
            print 'injecting values in html page' . "\n";
            my $i = 0;
            for my $value (@$data) {
                print $writeFh '[' . $i++ . ', ' . $value . '],' . "\n";

            }
            print "$i values written \n";
        } else {
            print $writeFh $line;
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