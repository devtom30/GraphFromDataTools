#!/usr/bin/perl

use strict;
use warnings;
use lib './lib';

use threads;
use threads 'exit' => 'threads_only';

use constant SERVICE_SLEEP_TIME  => 1000; # in milliseconds
use constant SERVICE_NAME        => "fusioninventory-agent-memory-log-tracker";
use constant SERVICE_DISPLAYNAME => "Fusioninventory Agent Memory Log Tracker ";

use POSIX ":sys_wait_h";
use File::Spec;
use File::Basename;

use English qw(-no_match_vars);
use Getopt::Long;
use Pod::Usage;

use Win32;
use Win32::Daemon;
use Win32::OLE;
use Win32::Service;
use File::Remove;

use GraphCreator;

BEGIN {
    open(STDOUT, ">C://stdout.log");
    open(STDERR, ">&STDOUT");
    select STDERR; $| = 1;  # make unbuffered
    select STDOUT; $| = 1;  # make unbuffered
}

delete($ENV{PERL5LIB});
delete($ENV{PERLLIB});

Getopt::Long::Configure( "no_ignorecase" );

my $options = {};

GetOptions(
    $options,
    'files=s',
    'register',
    'delete'
) or pod2usage(-verbose => 0);

pod2usage(-verbose => 0, -exitstatus => 0) if ($options->{help});

my $directory = dirname(File::Spec->rel2abs( __FILE__ ));
# on Win2k, Windows do not chdir to the bin directory
# we need to do it by ourself
chdir($directory);

if ($options->{register}) {
    exit(1) if (!$options->{files});

    my $ret = 0;

    my $libdir = $options->{libdir} || File::Spec->rel2abs($directory.'/../lib');

    my $service = {
        name    => SERVICE_NAME,
        display => SERVICE_DISPLAYNAME,
        path    => "$^X",
        parameters => "-I$libdir ".File::Spec->rel2abs( __FILE__ ) .' --files=' . $options->{files}
    };

    if (!Win32::Daemon::CreateService($service)) {
        my $lasterr = Win32::Daemon::GetLastError();
        if ($lasterr == 1073) {
            print "Service still registered\n";
        } elsif ($lasterr == 1072) {
            $ret = 1;
            print "Service marked for deletion. Computer must be rebooted before new service registration\n";
        } else {
            $ret = 2;
            print "Service not registered: $lasterr: ".Win32::FormatMessage($lasterr), "\n";
        }
    }

    exit($ret);

} elsif ($options->{delete}) {
    my $ret = 0;

    if (!Win32::Daemon::DeleteService("", SERVICE_NAME)) {
        my $lasterr = Win32::Daemon::GetLastError();
        if ($lasterr == 1060) {
            print "Service not present\n";
        } elsif ($lasterr == 1072) {
            $ret = 1;
            print "Service still marked for deletion. Computer must be rebooted\n";
        } else {
            $ret = 2;
            print "Service not removed $lasterr: ".Win32::FormatMessage($lasterr), "\n";
        }
    }

    exit($ret);
}

my @files = split (/,/, $options->{files});

my $callbacks = {
    start       => \&cb_start,
    timer       => \&cb_running,
    stop        => \&cb_stop,
    shutdown    => \&cb_shutdown,
    interrogate => \&cb_interrogate
};

Win32::Daemon::RegisterCallbacks($callbacks);

# Under newer win32 releases, setting accepted controls may be required
my $controls = SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN ;
Win32::Daemon::AcceptedControls($controls);

my $hashFiles = {};
for my $file (@$files) {
    $hashFiles->{$file} = '';
}

my %context = (
    last_state => SERVICE_STOPPED,
    start_time => time(),
    files => $hashFiles
);

Win32::Daemon::StartService( \%context, SERVICE_SLEEP_TIME);

sub cb_start {
    my( $event, $context ) = @_;

    Win32::Daemon::CallbackTimer(SERVICE_SLEEP_TIME);

    $context->{last_state} = SERVICE_RUNNING;
    Win32::Daemon::State(SERVICE_RUNNING);
}

sub cb_running {
    my( $event, $context ) = @_;

    while ( SERVICE_RUNNING == Win32::Daemon::State() ) {
        for my $file (@$files) {
            if ($context->{files->{$file}} && -f $context->{files->{$file}}) {
                File::Remove::remove($context->{files->{$file}});
            }
            my $fileName = $file;
            print 'writing html in ' . $fileName . "\n";
            my $context->{files->{$file}} = GraphCreator::createHtmlPageFromLogFile($fileName);
            sleep(1);
        }
        sleep(60);
    }
}

sub cb_stop {
    my( $event, $context ) = @_;

    $context->{last_state} = SERVICE_STOP_PENDING;
    Win32::Daemon::State(SERVICE_STOP_PENDING, 10000);
}

sub cb_shutdown {
    my( $event, $context ) = @_;

    $context->{last_state} = SERVICE_STOP_PENDING;
    Win32::Daemon::State(SERVICE_STOP_PENDING, 25000);
}

sub cb_interrogate {
    my( $event, $context ) = @_;

    Win32::Daemon::State($context->{last_state});
}

__END__

=head1 NAME

fusioninventory-win32-service - FusionInventory Agent service for Windows

=head1 SYNOPSIS

B<fusioninventory-win32-service> [--register|--delete|--help] [options]

  Options are only useful when registring or deleting the service. This
  is handy while using Fusioninventory agent from sources.

  Register options:
    -n --name=NAME                  unique system name for the service
    -d --displayname="Nice Name"    display name of the service
    --libdir=PATH                   full path to agent perl libraries
                                    use it if not found by the script

  Delete options:
    -n --name=NAME                  unique system name of the service
                                    to delete

  Samples to use from sources:
    perl bin/fusioninventory-win32-service --help
    perl bin/fusioninventory-win32-service --register -n fia-test -d "[TEST] FIA 2.3.18"
    perl bin/fusioninventory-win32-service --delete -n fia-test
