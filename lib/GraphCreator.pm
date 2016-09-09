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
    open($writeFh, '>' , $generatedFile) or die "can't open GENERATED file " . $generatedFile . ' : ' . $! . "\n";

    while (my $line = <$readFh>) {
        if ($line =~ /DATAHERE/) {
            my $i = 0;
            for my $value (@$data) {
                print $writeFh '[' . $i . ', ' . $value . '],' . "\n";
                $i++;
            }
        } else {
            print $writeFh $line;
        }
    }
    close $writeFh;
    close $readFh;

    return 1;
}

sub generateJSCodeFromData {
    my ($data) = @_;

    my $jsCode = [];
    my $i = 0;
    for my $value (@$data) {
        my $jsValue = '[' . $i . ', ' . $value . '],' . "\n";
        push @$jsCode, $jsValue;
        $i++;
    }

    return $jsCode;
}

sub createHtmlPageFromLogFile {
    my ($logfile, $outputFile) = shift;

    my $data = DataFromLogFile::extractGraphDataFromRelevantLines($logfile);
    my $generatedFile = $outputFile ? $outputFile : time . '_generatedFromFile.html';
    if (createHtmlPageFromData($data, $generatedFile)) {
        return $generatedFile;
    } else {
        return undef;
    }
}

1;