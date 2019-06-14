package GitHub::Repository;

use strict;
use warnings;
use feature qw/ say /;

use Moose;

has 'name'    => (is => 'ro');
has 'link'    => (is => 'ro');
has 'desc'    => (is => 'ro');
has 'license' => (is => 'ro');
has 'udt'     => (is => 'ro', isa => 'DateTime');
has 'stars'   => (is => 'ro');

sub print {
    my ($self) = shift;
    say $self->name;
    say $self->link;
    say $self->desc;
    say $self->license;
    say $self->udt->stringify;
    say $self->stars;
    say "\n\n";
}

1;
