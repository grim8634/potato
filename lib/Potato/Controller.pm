use utf8;
package Potato::Controller;
use Moose;

use Import::Into;
use Potato::Action;

has app => (
    is       => 'ro',
    weak_ref => 1,
);

has actions => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => 'setup_actions',
);
sub setup_actions {
    my $self = shift;
    my $classname = ref $self;

    my @actions;

    my @methods = $self->meta->get_method_with_attributes_list;
    for ( @methods ) {
        my $attrs = $self->meta->get_method( $_->name )->attributes;

        #should we store the meta method as well? ( $_ )???
        my $action = Potato::Action->new(
            subname   => $_->name,
            attrs     => $attrs,
            classname => $classname,
        );
        push @actions, $action;
    }

    \@actions;
}

sub import {
    my $target = caller;
    my $class = shift;

    push @$target::ISA, $class;

    strict->import::into( $target );
    warnings->import::into( $target );
    attributes->import::into( $target, () );
    Moose->import::into( $target );
    MooseX::MethodAttributes->import::into( $target );

    my @isas = $target->meta->superclasses;
    $target->meta->superclasses( @isas, $class );
}

__PACKAGE__->meta->make_immutable;