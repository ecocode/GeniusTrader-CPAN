 package Finance::GeniusTrader::Indicators::EVWMA;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# standards upgrade Copyright 2005 Thomas Weigert
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# ras hack based on version dated 24apr05 2780 bytes
# includes patches thru 9mar07
# $Id$

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES @DEFAULT_ARGS);

use Finance::GeniusTrader::Indicators;
use Finance::GeniusTrader::Prices;
use Finance::GeniusTrader::MetaInfo;

@ISA = qw(Finance::GeniusTrader::Indicators);
@NAMES = ("EVWMA");
@DEFAULT_ARGS = ("{I:Prices CLOSE}");

=head1 Finance::GeniusTrader::Indicators::EVWMA (Elastic Volume Weighted Moving Average)

=head2 Overview

The Elastic Volume Weighted Moving Average (eVWMA) differs from usual
average in that :

- It does not refer to any underlying averaging time period (for
example, 20 days, 50 days, 200 days). Instead, eVWMA uses share volume
to define the period of the averaging.

- It incorporates information about volume (and possibly time) in a
natural and logical way

- It can be derived from, and seen as an approximation to, a statistical
measure and thus has a solid mathematical justification.

=head2 =====>>>>>   SIGNIFICANT USAGE ISSUE   <<<<<=====

to use I:EVWMA one must have a database containing the number of
shares floating for each security being analyzed. this shares_float
database is only searched for in an xml file at /bourse/metainfo/"$code".xml

currently the beancounter database doesn't store this security attribute,
nor does beancounter fetch this value in the course of a normal daily update.

yahoo does provide the attribute via 'f6', but how one might create the
required xml file based database is not described.

=head2 Calculation

eVWMA(0) = Today's Close
eVWMA(i) = ( (Number of shares floating - Today's Volume) \
         * eVWMA(i-1) + Today's Volume * Today's Close ) \
         / Number of shares floating

=head2 Example

Finance::GeniusTrader::Indicators::EVWMA->new()

=head2 Links

http://www.christian-fries.de/evwma/
http://www.linnsoft.com/tour/techind/evwma.htm

=head2 Finance::GeniusTrader::Indicators::EVWMA::calculate($calc, $day)

=cut
sub initialize {
    my ($self) = @_;

    $self->{'metainfo'} = Finance::GeniusTrader::MetaInfo->new();
}

sub calculate {
    my ($self, $calc, $i) = @_;
    my $getvalue = $self->{'_func'};
    my $evwma_name = $self->get_name(0);
    my $prices = $calc->prices;
    my $evwma = 0;

    # Return if we have already the required data
    return if ($calc->indicators->is_available($evwma_name, $i));
    return if (! $self->check_dependencies($calc, $i));

    # Return if the metainfo file doesn't exist
    return if not (-e "/bourse/metainfo/" . $calc->code . ".xml");
       
    # Find the number of floating shares
    $self->{'metainfo'}->load("/bourse/metainfo/" . $calc->code . ".xml");
    my $floating_shares = $self->{'metainfo'}->get("floating_shares");
    
    for (my $n = 0; $n <= $i; $n++) {
    
	if ($n == 0) {
	    
	    # Set eVWMA(0) as Today's Close
	    $evwma = $self->{'args'}->get_arg_values($calc, $i, $n);
	    
	} else {

	    # Calculate the following eVWMA
            $evwma = (($floating_shares - $prices->at($n)->[$VOLUME])
             * $self->{'args'}->get_arg_values($calc, $i, $n - 1)
             + ($prices->at($n)->[$VOLUME]
             * $self->{'args'}->get_arg_values($calc, $i, $n)))
             / $floating_shares;
            
	}
        $calc->indicators->set($evwma_name, $i, $evwma);
    }
}

1;
