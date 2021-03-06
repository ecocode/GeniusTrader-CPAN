package Finance::GeniusTrader::Graphics::Object;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

use strict;
use Finance::GeniusTrader::Graphics::Graphic;
use Finance::GeniusTrader::Graphics::Tools qw(:color);
use Finance::GeniusTrader::Conf;

require Finance::GeniusTrader::Graphics::Object::Candle;
require Finance::GeniusTrader::Graphics::Object::CandleVolume;
require Finance::GeniusTrader::Graphics::Object::CandleVolumePlace;
require Finance::GeniusTrader::Graphics::Object::BarChart;
require Finance::GeniusTrader::Graphics::Object::Histogram;
require Finance::GeniusTrader::Graphics::Object::Marks;
#require Finance::GeniusTrader::Graphics::Object::PointAndFigure;
require Finance::GeniusTrader::Graphics::Object::Curve;
require Finance::GeniusTrader::Graphics::Object::Mountain;
require Finance::GeniusTrader::Graphics::Object::MountainBand;
require Finance::GeniusTrader::Graphics::Object::Text;
require Finance::GeniusTrader::Graphics::Object::Polygon;
require Finance::GeniusTrader::Graphics::Object::BuySellArrows;
require Finance::GeniusTrader::Graphics::Object::VotingLine;

=head1 Finance::GeniusTrader::Graphics::Object

A graphical object is a part of a graphic. It can display itself
on a picture.

=head1 FUNCTIONS TO IMPLEMENT

Each object will have to implement those functions.

=head2 $o->display($driver, $picture)

Display the object on the picture using the given driver. It may
use $o->{'zone'} and $o->{'source'} to get the data and display
itself in the good zone.

=head2 $o->init(...)

This function is called with the trailing arguments given to
the constructor.

=head1 GENERIC FUNCTIONS

=head2 Finance::GeniusTrader::Graphics::Object::<Something>->new($datasource, $zone, ...)

The constructor.

=cut
sub new {
    my $type = shift;
    my $class = ref($type) || $type;
    my $source = shift;
    my $zone = shift;

    my $self = { "source" => $source, "zone" => $zone,
		 "bg_color" => 
			get_color(Finance::GeniusTrader::Conf::get("Graphic::BackgroundColor")),
	         "fg_color" => 
			get_color(Finance::GeniusTrader::Conf::get("Graphic::ForegroundColor"))
	       };
    bless $self, $class;

    $self->init(@_);
    
    return $self;
}

=head2 $o->get_z_level()

=head2 $o->set_z_level($z)

Those two functions are used to manage the order in which the orders
are displayed. An object with a low Z level is drawn first.

=cut
sub set_z_level {
    my ($self, $z) = @_;
    $self->{'z'} = $z;
}

sub get_z_level {
    my ($self) = @_;
    return $self->{'z'};
}

=head2 $o->set_source($source)

=head2 $o->get_source()

Set/get the datasource associated to this object.

=cut
sub set_source {
    my ($self, $source) = @_;
    $self->{'source'} = $source;
}
sub get_source { $_[0]->{'source'} }

=head2 $o->set_zone($zone)

Set the zone in which the object will be displayed.

=cut
sub set_zone {
    my ($self, $zone) = @_;
    $self->{'zone'} = $zone;
}

=head2 $o->set_special_scale($scale)

Use a special scale to draw this object.

=cut
sub set_special_scale {
    my ($self, $scale) = @_;
    $self->{'special_scale'} = $scale;
}

=head2 $o->get_scale()

Return the associated scale. If it exists, it uses the special scale,
otherwise returns the default scale associated to the zone.

=cut
sub get_scale {
    my ($self) = @_;
    if (defined($self->{'special_scale'})) {
	return $self->{'special_scale'};
    }
    return $self->{'zone'}->get_default_scale();
}

=head2 $o->set_background_color($color)

Use this color as background color.

=cut
sub set_background_color {
    my ($self, $color) = @_;
    $self->{'bg_color'} = get_color($color);
}

=head2 $o->set_foreground_color($color)

Use this color as foreground color.

=cut
sub set_foreground_color {
    my ($self, $color) = @_;
    $self->{'fg_color'} = get_color($color);
}

1;
