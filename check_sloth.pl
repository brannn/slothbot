#!/usr/bin/perl -w

#
# Grab long-running httpd requests from servers' Apache scoreboards,
# log the server names, URIs, and connection times, then put the 
# data on a Beanstalkd tube for retrieval by an XMPP MUC bot.
# 

use strict;

use Parse::Apache::ServerStatus::Extended;
use Beanstalk::Client;

# File containing FQDN servers to be polled, one per line
my $hostfile = "hosts.dat";

# Log file for slothful URIs and times
my $logfile = "/tmp/sloth_uri.log";

# ServerPort
my $port = 8000;

# First scoreboard key
my $key1 = "m";

# First scoreboard key value
my $val1 = "W ";

my $key2 = "ss";
my $val2 = "5";

# Number of times per server both k/v pairs test true before producing output
my $thresh = "1";

# Alright, let's get started

my $beanstalk = Beanstalk::Client->new(
    {
        server       => "10.15.9.83",
        default_tube => "sloth",
    }
);

open LOG, ">> /tmp/sloth_uri.log" || die("Could not open log file!");

open( FILE, $hostfile ) || die("Could not open hosts file!");
my @hosts = <FILE>;

foreach my $server (@hosts) {
    my $count = 0;
    chomp $server;
    print "\n[$server]\n";
    my $parser = Parse::Apache::ServerStatus::Extended->new;
    $parser->request(
        url     => "http://$server:$port/status",
        timeout => 10
    ) || die $parser->errstr;
    my $stat = $parser->parse || die $parser->errstr;

    foreach my $i ( @{$stat} ) {
        if ( $i->{'m'} eq $val1 && $i->{'ss'} > $val2 ) {
            print LOG "[$server]\n";
            $count++;
            push( my @pids, $i->{'pid'} );
            my %sloth =
              ( pid => $i->{'pid'}, req => $i->{'request'}, sec => $i->{'ss'} );
            foreach my $key ( keys %sloth ) {
                my $value = $sloth{$key};
                print LOG "- $value\n";
            }
        }
    }

    my $job = $beanstalk->put(
        {
            data =>
              "$count slothful conns older than $val2 secs on $server:$port",
            priority => 100,
            ttr      => 300,
            delay    => 1,
        }

    # You may want to send MUC notifications less often than you log slothfuls
    ) unless ( $count < 5 );
}

close LOG;
