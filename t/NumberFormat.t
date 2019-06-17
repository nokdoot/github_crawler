#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/ say /;

use Number::Format;

my $nf = Number::Format->new();

my $number = '48.8k';
$number = uc ($number);
say $number;
my $a = $nf->unformat_number($number, base => 1000);
my $b = $nf->unformat_number('1k', base => 1000);

say $a;
say $b;
