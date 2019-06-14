#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/ say /;
use Data::Dumper;
use Cwd qw(abs_path);
use FindBin;
use lib abs_path("$FindBin::Bin/lib");

use HTTP::Request;
use URL::Encode qw/ url_encode_utf8 /;
use DateTime::Format::Strptime;

my $strp = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%dT%TZ', # 2016-11-04||T||18:36:50||Z
    locale    => 'ko_KR',
    time_zone => 'Asia/Seoul',
);


use GitHub::Crawler;
use GitHub::Repository;

my %params = (
    p    => 1,                      # page
    l    => 'Perl',                 # language
    q    => 'perl',                 # query
    o    => 'desc',                 # order (desc|asc)
    s    => 'updated',              # sort
    type => 'Repositories',         # Repositories (fixed)
);

my $url = GitHub::Crawler->make_url(\%params); 
my $request = HTTP::Request->new(GET => $url);
my $response = GitHub::Crawler->response($request);
my $content = $response->content;

my $dom = GitHub::Crawler->html_dom($content);
my $items = $dom->at('ul.repo-list')->children; 

=encoding utf8
=pod

 ul.repo-list
    li.repo-list-item
        div1
            h3
                a[href="$link"] - "$name"
            (p) - "$desc"
            (div)
            div
                (p) - "$license"
                p
                    relative-time[datetime="$udt"]
                (p) - "$issue"
        div2
            div
                div
                    span
                        span
                        span - "$lang"
            (div)
                a - "$stars"

=cut

my @repos = ();

$items->each( sub {
    my $e = shift;
    my $div1 = $e->at('div:nth-child(1)');
    my $div2 = $e->at('div:nth-child(2)');

    my $e_in_div2 = $div2->children;
    my $lang = "";
    my $stars = 0;
    if ( $e_in_div2->size == 2 ) {
        $stars = $e_in_div2->last->at('a')->all_text;
        trim($stars);
    }
    $lang = 
        $e_in_div2->first->at('div span')->children->last->all_text;
    trim($lang);

    # name
    my $h3 = $div1->at('h3');
    my $name = $h3->all_text;
    trim($name);

    # link
    my $link = "https://github.com";
    my $suffix_of_link = $h3->at('a')->attr('href');
    trim($suffix_of_link);
    $link .= $suffix_of_link;

    # desc
    my $p = $e->at('p:nth-child(2)');
    my $desc = "";
    $desc = $p->all_text if $p;
    trim($desc);

    my $e_in_div1 = undef;
    $e_in_div1 = $p->following  if  defined $p;
    $e_in_div1 = $h3->following if !defined $e_in_div1 ;

    # license, udt, issue
    my $div_of_license_udt_issue = $e_in_div1->last;
    $p = $div_of_license_udt_issue->children;    # new/different $p;
    my ($license, $udt_str, $issue) = 
        extract_license_udt_issue(
            $div_of_license_udt_issue->children
        );
    trim($license), trim($udt_str), trim($issue), mtrim($issue);
    my $udt = $strp->parse_datetime($udt_str);

    my $repo = GitHub::Repository->new(
                name    => $name,
                link    => $link,
                desc    => $desc,
                license => $license,
                udt     => $udt,
                stars   => $stars,
    );

    push @repos, $repo;

});

for ( @repos ) {
    $_->print;
}

sub selector {
    my $e = shift;
    my $num = shift;
    say $e->selector;
}

sub extract_license_udt_issue {
    my $collection = shift;
    my $license = "";
    my $udt_str = "";
    my $issue = "";

    my $flag_of_udt_p = 0;

    $collection->each( sub {
        my ($e, $ord) = @_;
        my $tag_relative_time = undef;
        if ( $tag_relative_time = $e->at('relative-time') ) {
            $flag_of_udt_p = 1;
            $udt_str = $tag_relative_time->attr('datetime');
            return;
        }
        $license = $e->all_text 
                        if !$flag_of_udt_p;
        $issue = $e->all_text if $flag_of_udt_p;
    });
    
    return ($license, $udt_str, $issue);
}

sub trim {
    $_[0] =~ s/\s+$//; $_[0] =~ s/^\s+//;
}

sub mtrim {
    $_[0] =~ s/\s{2,}/ /;
}
