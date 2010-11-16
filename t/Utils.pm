package  t::Utils;
use strict;
use warnings;
use utf8;
use lib './t/';

sub import {
    strict->import;
    warnings->import;
    utf8->import;
}

1;
