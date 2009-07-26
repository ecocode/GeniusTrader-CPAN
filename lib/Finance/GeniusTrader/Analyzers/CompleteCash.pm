package GT::Analyzers::CompleteCash;

# Copyright 2003 Oliver Bossert
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES @DEFAULT_ARGS);

use GT::Analyzers;
use GT::Calculator;

@ISA = qw(GT::Analyzers);
@NAMES = ("CompleteCash[#*]");
@DEFAULT_ARGS = ();

=head1 NAME

  GT::Analyzers::CompleteCash - Returns the cash-part of the evaluation-history

=head1 DESCRIPTION 

Returns the cash-part of the evaluation-history

=head2 Parameters

none

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

    my @ret = ();

    foreach my $date ( sort { $a cmp $b } keys %{$portfolio->{'evaluation_history'}} ) {
      push @ret, $portfolio->{'evaluation_history'}->{$date}->[0];
    }

    $calc->indicators->set($name, $last, \@ret);
}

1;
