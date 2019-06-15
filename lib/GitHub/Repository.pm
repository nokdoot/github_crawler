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
    my ($self, $fh) = @_;
    say $fh $self->name;
    say $fh $self->link;
    say $fh $self->desc;
    say $fh $self->license;
    say $fh $self->udt->stringify;
    say $fh $self->stars;
    say $fh "\n\n";
}

1;
