package Finance::GeniusTrader::Registry;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# Copyright 2008 Thomas Weigert
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# $Id$

use strict;
use vars qw(@EXPORT @ISA);

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(get_name get_nb_values build_object_name);

=head1 NAME

Finance::GeniusTrader::Registry - Generic registry functions

=head1 DESCRIPTION

This module is used by Finance::GeniusTrader::Indicators, Finance::GeniusTrader::Signals and Finance::GeniusTrader::Systems
to keep a list of available objects. Those objects can be reused
with different datas.

=over

=item C<< Finance::GeniusTrader::Registry::get_registered_object($repository, $name) >>

Returns the object corresponding to $name if available. Otherwise
returns undef.

=cut
sub get_registered_object {
    my ($repository, $name) = @_;

    if (exists $repository->{$name}) {
        return $repository->{$name};
    }
    return undef;
}

=item C<< Finance::GeniusTrader::Registry::register_object($repository, $name, $object) >>

Register the object $object under the name $name. Replaces any previous
object registered under the same name.

=cut
sub register_object {
    my ($repository, $name, $object) = @_;

    $repository->{$name} = $object;
}

=item C<< Finance::GeniusTrader::Registry::get_or_register_object($repository, $name, $object) >>

If an object corresponding to name $name is already registered then
returns this object. Otherwise register $object under the name
$name.

This function is intented to be used by constructor of objects. Once
the constructor know the name of the object, it uses this function
to bless the object reference. It will check if an object with the same
name exists. In that case the registered object is used instead of creating
a new one. Otherwise the object in creation is blessed, stored in
the registry and returned.

Example:

  sub new {
      my $type = shift;
      my $class = ref($type) || $type;

      # Get the name of the object
      my $name = get_indicator_name(...);
      my $self = {};
      
      # Check the registry and register it
      $self = Finance::GeniusTrader::Indicators::get_or_register_object($name, $self);

      return $self;
  }

=cut
sub get_or_register_object {
    my ($repository, $name, $object) = @_;
    
    if (exists $repository->{$name}) {
        return $repository->{$name};
    }

    $repository->{$name} = $object;
}

=item C<< Finance::GeniusTrader::Registry::manage_object($repository, \@NAMES, $obj, $class, $args, $key) >>

Manage the creation of a new object. Build their names, stores and/or
retrieve the object from the database. Calls initialize for a new object.

=cut
sub manage_object {
    my ($repo, $names, $obj, $class, $args, $key) = @_;
    
    # Create the various names of the object
    $obj->{'key'} = $key;
    for (my $i = 0; $i < scalar(@{$names}); $i++)
    {
        $obj->{'names'}[$i] = build_object_name($names->[$i], $args, $key);
    }
    # Create name to lookup in the data base
    $class =~ /.*\:\:(.*)$/o;
    my $object_name = "${1}[";
    if (ref($args) =~ /ARRAY/) {
        $object_name .= join(',',@{$args});
    } elsif (ref($args) =~ /Finance::GeniusTrader::ArgsTree/) {
        $object_name .= join(',',$args->get_arg_names());
    }
    $object_name .= ']';
    $object_name .= "($key)" if ($key);

    # register or retrieve this object
    my $newobj = get_or_register_object($repo, $object_name, $obj);

    if ($newobj == $obj) {
        # We're really creating an object
        bless $obj, $class;
        $obj->initialize();
    } else {
        # We're just reusing an object
    }
    return $newobj;
}

=item C<< Finance::GeniusTrader::Registry::build_object_name($encoded, [ @args ], $key) >>

Returns the real $name of the object by substitution of #1, #2 (and so on)
by the real values of the parameters (given in the second argument).
"($key)" is appended at the end. It's used to differentiate similar
objects but using a different input method for example (think about
indicators like "Average" working on prices or any other value).

=cut
sub build_object_name {
    my ($name, $args, $key) = @_;
    $name =~ s/,\s*/, /go;
    if (ref($args) =~ /ARRAY/) {
	$name =~ s/#\*/join(", ",@{$args})/ge;
	for(my $i = 1; $i <= scalar(@{$args}); $i++)
	{
	    $name =~ s/#$i/$args->[$i-1]/;
	}
    } elsif (ref($args) =~ /Finance::GeniusTrader::ArgsTree/) {
	$name =~ s/#\*/join(", ",$args->get_arg_names())/ge;
	my $nb = $args->get_nb_args();
	for(my $i = 1; $i <= $nb; $i++)
	{
	    $name =~ s/#$i/$args->get_arg_names($i)/ge;
	}
    }
    $name .= "($key)" if ($key);
    return $name;
}

=item C<< Method for "named" objects >>

 get_name() or get_name($i)
 get_nb_values()

=cut
sub get_name {
    my ($self, $n) = @_;
    
    if (defined($n)) {
        return $self->{'names'}[$n];
    } else {
        return $self->{'names'}[0];
    }
}
sub get_nb_values {
    my ($self) = @_;
    return scalar(@{$self->{'names'}});
}

=pod

=back

=cut
1;
