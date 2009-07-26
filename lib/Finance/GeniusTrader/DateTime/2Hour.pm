package GT::DateTime::2Hour;

# Copyright 2000-2002 Rapha�l Hertzog, Fabien Fulhaber
# Copyright 2005 Jo�o Antunes Costa
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

use strict;
use vars qw();

use GT::DateTime;
use Time::Local;

=head1 GT::DateTime::2Hour

This module treat dates describing the 2Hour timeframe. They have the following format :
YYYY-MM-DD HH:00:00

=cut
sub map_date_to_time {
    my ($value) = @_;
	my ($date, $time) = split / /, $value;
    my ($y, $m, $d) = split /-/, $date;
	$time = "00:00:00" if (!defined($time));
	my ($h, , ) = split /:/, $time;
	if ($h >=22) {$h=22}
	elsif ($h>=20) {$h=20}
	elsif ($h>=18) {$h=18}
	elsif ($h>=16) {$h=16}
	elsif ($h>=14) {$h=14}
	elsif ($h>=12) {$h=12}
	elsif ($h>=10) {$h=10}
	elsif ($h>=8) {$h=8}
	elsif ($h>=6) {$h=6}
	elsif ($h>=4) {$h=4}
	elsif ($h>=2) {$h=2}
	else {$h=0}
    return timelocal(0, 0, $h, $d, $m - 1, $y - 1900);
}

sub map_time_to_date {
    my ($time) = @_;
    my ($sec, $min, $h, $d, $m, $y, $wd, $yd) = localtime($time);

	if ($h >=22) {$h=22}
	elsif ($h>=20) {$h=20}
	elsif ($h>=18) {$h=18}
	elsif ($h>=16) {$h=16}
	elsif ($h>=14) {$h=14}
	elsif ($h>=12) {$h=12}
	elsif ($h>=10) {$h=10}
	elsif ($h>=8) {$h=8}
	elsif ($h>=6) {$h=6}
	elsif ($h>=4) {$h=4}
	elsif ($h>=2) {$h=2}
	else {$h=0}

    return sprintf("%04d-%02d-%02d %02d:00:00", $y + 1900, $m + 1, $d, $h);
}

1;
