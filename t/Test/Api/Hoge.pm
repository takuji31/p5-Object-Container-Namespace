package  Test::Api::Hoge;
use strict;
use warnings;

sub new {
    bless {},shift;
}

sub fuga {
    return 'Hello Container!';
}

1;
