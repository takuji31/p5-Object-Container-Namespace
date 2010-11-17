package Object::Container::Namespace;
use strict;
use warnings;

use String::CamelCase qw/camelize/;
use Carp();
use UNIVERSAL::require;
use base qw/Class::Singleton/;

our $VERSION = '0.01';

sub import {
    my $class  = shift;
    my $caller = caller;

    if ( $_[0] && $_[0] eq '-base' ) {

        # base

        {
            no strict 'refs';
            push @{"$caller\::ISA"}, $class;
        }

        my $instance_table   = {};
        my $registered_class = {};
        {
            no strict 'refs';
            *{"$caller\::_instance_table"}     = sub {$instance_table};
            *{"$caller\::_registered_classes"} = sub {$registered_class};
            *{"$caller\::register"}            = sub { _register( $caller, @_ ) };
        }
        $caller->initialize(@_);
    }
    else {

        # export methods
        my @export_names = @_;

        {
            no strict 'refs';
            *{"$caller\::container"} = sub {
                my $pkg = shift;
                return $pkg ? $class->get($pkg) : $class;
            };
        }

        for my $export_name ( @export_names ) {
            $class->register_namespace( $caller, $export_name );
        }

    }
}

sub initialize {'DUMMY'}

sub _register {
    my $class       = shift;
    my $pkg         = shift;
    my $initializer = $_[0];
    my @options     = @_;

    unless ($pkg) {
        Carp::croak("Register name is empty!");
    }
    unless ( defined $initializer
        && ref($initializer) eq 'CODE'
        && scalar @options == 1 )
    {
        $initializer = sub {
            my $self = shift;
            $self->load_class($pkg);
            $pkg->new(@options);
        };
    }

    #register classes
    $class->_registered_classes->{$pkg} = $initializer;
}

sub get {
    my ( $class, $pkg ) = @_;

    my $self = ref($class) ? $class : $class->instance;

    my $obj = $class->_instance_table->{$pkg};

    unless ($obj) {
        my $code = $class->_registered_classes->{$pkg};
        unless ($code) {
            Carp::croak("$pkg is not registered!");
        }
        $obj = $code->($self);
    }

    return $obj;
}

sub register_namespace {
    my ( $class, $caller, $namespace ) = @_;

    unless ($namespace) {
        return;
    }

    my $self = ref($class) ? $class : $class->instance;
    ( my $basename = ref($class) ? ref($class) : $class )
        =~ s/::[a-zA-Z0-9]+$//;

    {
        no strict 'refs';
        *{"$caller\::$namespace"} = sub {
            my $pkg = shift;
            my $class_name;
            if( $pkg ) {
                $class_name = join '::', $basename, camelize($namespace), camelize($pkg);
                #initial access
                unless ( $class->_registered_classes->{$class_name} ) {
                    register($class,$class_name);
                }
            }

            return $pkg ? $class->get($class_name) : $class;
        };
    }

}

sub load_class {
    my ( $class, $pkg ) = @_;
    $pkg->require or die $@;
}

1;
__END__

=head1 NAME

Object::Container::Namespace - Container with name space register

=head1 SYNOPSIS

    package  MyApp::Container;
    use strict;
    use warnings;
    use Object::Container::Namespace -base;
    register 'db' => sub {
        my $self = shift;
        MyApp::DB->new;
    };

    package  Hoge::Api::Wassr;
    use strict;
    use warnings;

    sub new {
        bless {},shift;
    }

    sub login { 'do something' }

    package  Hoge::Pages::Fuga;
    use strict;
    use warnings;
    use MyApp::Container qw/api/;

    sub dispatch_index {
        my $self = shift;

        #get registered object
        container('db')->search();

        #get registered object by namespace register
        api('wassr')->login('wasao');
        #call Hoge::Api::Twitter->login
        api('twitter')->login('tweet');
    }

=head1 DESCRIPTION

Object::Container::Namespace is Container with name space register

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

Object::Container Kamui::Container

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
