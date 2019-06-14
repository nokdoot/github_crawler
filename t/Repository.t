#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use feature qw/ say /;

use Cwd qw(abs_path);
use FindBin;
use lib abs_path("$FindBin::Bin/../lib");

use DateTime;

use GitHub::Repository;

my $repo = GitHub::Repository->new(
    name    => 'blogvillain',
    link    => 'https://github.com/nokdoot/blog_villain',
    desc    => "viallin's blog",
    license => "ndt license",
    udt     =>  DateTime->now,
    stars   => 0,
);

say $repo;
