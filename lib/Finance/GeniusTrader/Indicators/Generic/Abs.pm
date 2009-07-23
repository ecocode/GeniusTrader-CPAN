package GT::Indicators::Generic::Abs;

# Copyright 2008 Jo�o Antunes Costa
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# Standards-Version: 1.0

use strict;
use vars qw(@ISA @NAMES);

use GT::Indicators;
@ISA = qw(GT::Indicators);

@NAMES = ("Abs[#1]");

=head1 NAME

GT::Indicators::Generic::Abs - Return the absolute value of its 1st parameter

=head1 DESCRIPTION



=cut
sub initialize {
    my ($self) = @_;
}

sub calculate {
	my ($self, $calc, $i) = @_;
	my $name = $self->get_name;

	return if ($calc->indicators->is_available($name, $i));

	my $val = $self->{'args'}->get_arg_values($calc, $i, 1);
	return unless (defined($val));
	my $res = abs($val);
	$calc->indicators->set($name, $i, $res);
}