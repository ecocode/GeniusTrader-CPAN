package GT::DB;

# Copyright 2000-2004 Rapha�l Hertzog, Fabien Fulhaber
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

use strict;

our $loaded_sharenames = 0;
our %sharenames;

=head1 NAME

GT::DB - Database to retrieve (an history of) prices of various shares

=head1 DESCRIPTION

No documentation available. Look at the DB::* modules for
real exemples.

=cut

sub has_code {
    my ($self, $code) = @_;
    # Default implementation is a kludge.
    # We have no way to know if the underlying database has the code
    # without trying to retrieve the prices
    my $name = $self->get_name($code);
    if (defined($name) && $name ne "") {
	return 1;
    } else {
	return 0;
    }
}

=over

=item C<< get_name ($code) >>

Returns the long name of the market (if defined). 

See also ~/.gt/sharenames which contains lines of the form
<code>\t<long name>
mapping a market code to its long name.

=back

=cut

sub get_name {
    my ($self, $code) = @_;

    my $name = $self->get_db_name($code);
    return $name if (defined($name) && $name);

    if (! $loaded_sharenames) {
        my $file = GT::Conf::_get_home_path()."/.gt/sharenames";
        if (-e $file) {
            open(NAMES, "<", "$file") || die "Can't open $file : $!\n";
            foreach (<NAMES>) {
                chomp;
                next unless $_;
                my ($c, $d) = split /\t/;
                if ($c) {
                    $sharenames{$c} = $d;
                }
            }
            close NAMES;
        }
        $loaded_sharenames = 1;
    }
    ( exists $sharenames{$code} )
     ? return $sharenames{$code}
     : return "";
}

sub get_db_name {
    return undef;
}

1;
