package Data::ObjectMapper::Mapper::Attribute;
use strict;
use warnings;
use Carp::Clan;
use Params::Validate qw(:all);
use Class::MOP;

sub new {
    my $class  = shift;
    my $mapper = shift;

    my %option = validate(
        @_,
        {
            include    => { type => ARRAYREF, default => +[] },
            exclude    => { type => ARRAYREF, default => +[] },
            prefix     => { type => SCALAR,   default => q{} },
            properties => { type => HASHREF|ARRAYREF,  default => +{} },
        }
    );
    $option{table} = $mapper->table;

    my $type = 'Hash';
    if ( ref $option{properties} eq 'ARRAY' ) {
        confess "not match constructor{arg_type}.(properties is HASHREF)"
            unless $mapper->constructor->{arg_type} eq 'ARRAY'
                || $mapper->constructor->{arg_type} eq 'ARRAYREF';
        $type = 'Array';
    }

    my $attribute_class = $class . '::' . $type;
    Class::MOP::load_class($attribute_class)
        unless Class::MOP::is_class_loaded($attribute_class);
    my $self = bless \%option, $attribute_class;
    $self->init;

    return $self;
}

sub table          { $_[0]->{table} }
sub include        { $_[0]->{include} }
sub exclude        { $_[0]->{exclude} }
sub prefix         { $_[0]->{prefix} }
sub properties     { $_[0]->{properties} }
sub property_names { confess "Abstruct Method" }
sub property       { confess "Abstruct Method" }

sub lazy_column {
    my ( $self, $name ) = @_;
    my $prop = $self->property($name);
    if( $prop->lazy eq 1 ) {
        return $name => $prop->{isa};
    }
    elsif( $prop->lazy ) {
        my %lazy_column;
        for my $prop_name ( $self->property_names ) {
            my $other_prop = $self->property($prop_name);
            $lazy_column{$prop_name} = $other_prop->{isa}
                if $other_prop->lazy eq $prop->lazy;
        }
        return %lazy_column;
    }
    else {
        return;
    }
}

1;
