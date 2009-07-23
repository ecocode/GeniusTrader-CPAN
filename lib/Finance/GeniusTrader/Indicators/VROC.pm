package GT::Indicators::VROC;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES @DEFAULT_ARGS);

use GT::Indicators;
use GT::Indicators::ROC;
use GT::Prices;

@ISA = qw(GT::Indicators);
@NAMES = ("VROC[#1]");
@DEFAULT_ARGS = (12, "{I:Prices VOLUME}");

=head1 GT::Indicators::VROC

=head2 Overview

The VROC is the Volume Rate Of Change.

=head2 Calculation

VROC = ((Volume(i) * 100) / Volume(i-n)) - 100

=head2 Parameters

The standard VROC is equal to GT::Indicators::ROC->new([12], "VOLUME", $GET_VOLUME)

=head2 Example

GT::Indicators::VROC->new()
GT::Indicators::VROC->new([20])

=cut

sub initialize {
    my $self = shift;
    $self->{'roc'} = GT::Indicators::ROC->new([ $self->{'args'}->get_arg_names(1), $self->{'args'}->get_arg_names(2) ] );
    $self->add_indicator_dependency($self->{'roc'}, 1);
}

=head2 GT::Indicators::VROC::calculate($calc, $day)

=cut
sub calculate {
    my ($self, $calc, $i) = @_;
    my $indic = $calc->indicators;
    my $roc = $self->{'roc'};
    my $roc_name = $roc->get_name;
    my $vroc_name = $self->get_name(0);

    return if ($indic->is_available($vroc_name, $i));
    return if (! $self->check_dependencies($calc, $i));
    
    # Get and retrun the results from the ROC indicator
    my $vroc_value = $indic->get($roc_name, $i);
    $indic->set($vroc_name, $i, $vroc_value);
}

1;
