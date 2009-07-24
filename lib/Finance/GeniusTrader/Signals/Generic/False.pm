package Finance::GeniusTrader::Signals::Generic::False;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES);

use Finance::GeniusTrader::Signals;
use Finance::GeniusTrader::Eval;
use Finance::GeniusTrader::Tools qw(:generic);

@ISA = qw(Finance::GeniusTrader::Signals);
@NAMES = ("False");

=head1 False

Always return false.

=head2 EXAMPLE

    S:Generic:False

=cut
sub initialize {
    my ($self) = @_;

}

sub detect {
    my ($self, $calc, $i) = @_;
    $calc->signals->set($self->get_name, $i, 0);
}

1;
