package Object::Container::Namespace;
use strict;
use warnings;

use String::CamelCase qw/camelize/;
use Carp();
use base qw/Class::Singleton/;

our $VERSION = '0.01';

sub import {
    my $class  = shift;
    my $caller = caller;

    if( $_[0] && $_[0] eq '-base' ) {
        # base

        {
            no strict 'refs';
            push @{"$caller\::ISA"},$class;
        }

        my $instance_table = {};
        my $registered_class = {};
        {
            no strict 'refs';
            *{"$caller\::_instance_table"} = sub { $instance_table };
            *{"$caller\::_registered_classes"} = sub { $registered_class };
        }

    }
    else {
        # export methods

    }

    $caller->initialize(@_);
}

sub initialize { 'DUMMY' }

sub register {
    my $class       = shift;
    my $pkg         = shift;
    my $initializer = $_[0];
    my @options     = @_;

    unless ( $pkg ) {
        Carp::croak("Register name is empty!");
    }
    unless ( defined $initializer && ref($initializer) eq 'CODE' && scalar @options == 1 ){
        $initializer = sub {
            my $self = shift;
            $self->load_class($pkg);
            $pkg->new(@options);
        }
    }

    #register classes
    $class->_registered_classes->{$pkg} = $initializer;
}

sub get {
    my ( $class, $pkg ) = @_;

    my $self = ref($class) ? $class : $class->instance;

    my $obj = $class->_instance_table->{$pkg};

    unless ( $obj ) {
        my $code = $class->_registered_class->{$pkg};
        unless ( $code ) {
            Carp::croak("$pkg is not registered!");
        }
        $obj = $code->($self);
    }

    return $obj;
}

1;
__END__

=head1 NAME

Object::Container::Namespace -

=head1 SYNOPSIS

  use Object::Container::Namespace;

=head1 DESCRIPTION

Object::Container::Namespace is

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
