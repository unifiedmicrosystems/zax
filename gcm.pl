#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;

######################
# config
my $url = "http://localhost/push-server";
my $logfile = "/tmp/gcm.log"

# end config
######################

use Data::Dumper;
use URI::Escape;


open(my $log, ">>", $logfile);
flock $log, 2;
my $datestring = localtime();
print $log $datestring . "\n";

#print $log Dumper(\@ARGV);

my @lines = split(/\n/, $ARGV[2]);

print $log Dumper(\@lines);

my %msg = ();
for my $l (@lines) {
	my ($key, $val) = split(/=/, $l, 2);
	# the message from zabbix contains carriage returns, which caused problems in the url.
	# the following line removes any carriage returns.
	$val =~ s/\r|\n//g;
	$msg{$key} = $val;
}

#print $log Dumper(\%msg);

#$url .= uri_escape("{\"triggerid\": " . $ARGV[1] . ", \"message\": \"" . $ARGV[2] . "\"}");
my $json = "{\"triggerid\": " . $ARGV[1] . ", \"message\": \"" . $msg{"message"} . "\",\"status\": \"" . $msg{"status"} . "\"}";

#print $log "$url\n";
print $log "\n";
print $log "$json\n";
print $log "\n";
#print $log post($url, $json);
#print $log "\n------------------------------------\n\n";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(POST => $url);
$req->header('content-type' => 'application/json');

$req->content($json);

my $response = $ua->request($req);
if ($response->is_success) {
    my $message = $response->decoded_content;
    print "Received reply: $message\n";
}
else {
    print "HTTP POST error code: ", $response->code, "\n";
    print "HTTP POST error message: ", $response->message, "\n";
}

close($log);

