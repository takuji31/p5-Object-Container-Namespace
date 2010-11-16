package  Test::Container;
use strict;
use warnings;
use Object::Container::Namespace -base;

register foo => sub {
    my $self = shift;
    return 'bar';
};

1;
