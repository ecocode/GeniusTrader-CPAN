package GT::Analyzers::ProfitFactor;

# Copyright 2003 Oliver Bossert
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES @DEFAULT_ARGS);

use GT::Analyzers;
use GT::Calculator;

@ISA = qw(GT::Analyzers);
@NAMES = ("ProfitFactor[#*]");
@DEFAULT_ARGS = ("{A:Sum {A:Gain}}", "{A:Sum {A:Losses}}");

=head1 NAME

  GT::Analyzers::Profitfactor - Calculates the profitfactor

=head1 DESCRIPTION 

Calculate the Profitfactor by dividing the sum of the gains by the sum
of the losses.

=head2 Parameters

=over

=item Sum of the Gains

=item Sum of the Lossse

=back

=cut

sub initialize {
    1;
}

sub calculate {
    my ($self, $calc, $last, $first, $portfolio) = @_;
    my $name = $self->get_name;

    if ( !defined($portfolio) ) {
	$portfolio = $calc->{'pf'};
    }
    if ( !defined($first) ) {
	$first = $calc->{'first'};
    }
    if ( !defined($last) ) {
	$last = $calc->{'last'};
    }

    if ( defined($portfolio) ) {
	$self->{'portfolio'} = $portfolio;
    }

    my $avg_g = $self->{'args'}->get_arg_values($calc, $last, 1);
    my $avg_l = $self->{'args'}->get_arg_values($calc, $last, 2);
    my $ret =  0;
    $ret = $avg_g / ($avg_l * -1) unless ( $avg_l == 0 );

    $calc->indicators->set($name, $last, $ret);
}

1;
