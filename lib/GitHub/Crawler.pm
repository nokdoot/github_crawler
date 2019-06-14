package GitHub::Crawler;

use strict;
use warnings;
use feature qw/ say /;

use HTTP::Request;
use LWP::UserAgent;
use Mojo::DOM;
use URL::Encode qw/ url_encode_utf8 /;

my $github = "https://github.com/search";

sub make_url {
    my ($c, $params) = @_;

    my $param_str = '?';
    for ( keys %$params ) {
        $param_str .= "$_=$params->{$_}&";
    }
    my $url = $github.$param_str;
    return $url;
}

sub response {
    my ($class, $request) = @_;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($request);
    return $response;
}

sub html_dom {
    my ($class, $html) = @_;
    my $dom = Mojo::DOM->new($html);
    return $dom;
}

1;
