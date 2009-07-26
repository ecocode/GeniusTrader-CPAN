package GT::Graphics::DataSource::Prices;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

use strict;
use vars qw(@ISA);

@ISA = qw(GT::Graphics::DataSource);

use GT::Prices;
use GT::Graphics::DataSource;
use GT::Tools qw(:math);

=head1 GT::Graphics::DataSource::Prices

This datasource provides prices information.
It uses a GT::Prices object as a basis.

=head2 GT::Prices::DataSource::Prices->new($prices)

Create a new prices data source.

=cut
sub new {
    my $type = shift;
    my $class = ref($type) || $type;
    my $prices = shift;
    
    my $self = { "prices" => $prices };
    
    bless $self, $class;

    $self->set_available_range(0, $prices->count() - 1);
    $self->set_selected_range($self->get_available_range());
    
    return $self;
}

sub is_available {
    my ($self, $index) = @_;
    if (($index >= 0) && ($index < $self->{'prices'}->count()))
    {
	return 1;
    }
    return 0;
}

sub get {
    my ($self, $index) = @_;
    return $self->{'prices'}->at($index);
}

sub update_value_range {
    my ($self) = @_;
    my ($start, $end) = $self->get_selected_range();
    my ($min, $max);
    $min = $self->{'prices'}->at($start)->[$LOW];
    $max = $self->{'prices'}->at($start)->[$HIGH];
    for(my $i = $start; $i <= $end; $i++) {
	$min = min($self->{'prices'}->at($i)->[$LOW], $min);
	$max = max($self->{'prices'}->at($i)->[$HIGH], $max);
    }
    $self->set_min_value($min);
    $self->set_max_value($max);
}

1;
