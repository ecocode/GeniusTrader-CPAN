package GT::Signals::Generic::True;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES);

use GT::Signals;
use GT::Eval;
use GT::Tools qw(:generic);

@ISA = qw(GT::Signals);
@NAMES = ("True");

=head1 True

Always return true.

=head2 EXAMPLE

    S:Generic:True

=cut
sub initialize {
    my ($self) = @_;

}

sub detect {
    my ($self, $calc, $i) = @_;
    $calc->signals->set($self->get_name, $i, 1);
}

1;
