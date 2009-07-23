package GT::OrderFactory::MarketPrice;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES @DEFAULT_ARGS);

use GT::OrderFactory;

@ISA = qw(GT::OrderFactory);
@NAMES = ("MarketPrice");
@DEFAULT_ARGS = ();

=head1 NAME

GT::OrderFactory::MarketPrice

=head1 DESCRIPTION

Create an order at market price.

=cut
sub create_buy_order {
    my ($self, $calc, $i, $sys_manager, $pf_manager) = @_;

    return $pf_manager->buy_market_price($calc, $sys_manager->get_name);
}

sub create_sell_order {
    my ($self, $calc, $i, $sys_manager, $pf_manager) = @_;

    return $pf_manager->sell_market_price($calc, $sys_manager->get_name);
}

1;
