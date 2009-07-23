package GT::DB::MetaStockReader;
# Copyright 2003-2005 Yannick Tournedouet
# This file is distributed under the terms of the General Public License
# version 2 or (at your option) any later version.

# v1.0 : Initial version
# v1.1 29/07/2004 : Function "initialize" read now all the MASTER and XMASTER files find in the directory and the sub directory
#      : Use ref for the hash
#      : Use "/" instead of "\\" for a better compatiblity with system UNIX
# v1.2 30/07/2004 : use hash of hash for the security list for a better performance.
#      : bug 1.1 fixed -> XMASTER read MASTER file
# v1.3 27/08/2004 : fixed bug in the read_xmaster and read_master method when the code is the not ISIN code
# v1.4 23/05/2005 : fixed a bug in the coding float number format.
# v1.5 27/05/2005 : fixed a warning with the 'pack' function when a Byte was > 255.
#		: test if security already exists before putting in the table.
# v1.6 04/06/2005 : Changed the DB object interface to allow better timeframe support (Jo�o Costa)

# ras 9mar08 : pod explaining GT::DB::MetaStockReader and GT::DB::MetaStock usage

use strict;
use vars qw(@ISA);

use GT::DB;
use GT::Prices;
use GT::Conf;
use GT::DateTime;

@ISA = qw(GT::DB);

=head1 DB::MetaStockReader access module

=head2 Overview

The MetaStockReader access module is able to retrieve quotes from almost any
type of MetaStock database.

This module does not require any other code
to support its operation and it is not intended to be used with
GT::DB::MetaStock and, although named MetaStockReader, it is not
the companion program required by GT::DB::MetaStock.

=head2 Synopsis

   my $db = create_standard_object("DB::" . GT::Conf::get("DB::module"));
   $db->initialize;
   $db->get_prices("FR0000130007");
   $db->disconnect;
or
   my $db = create_standard_object("DB::" . GT::Conf::get("DB::module"));
   $db->get_prices("FR0000130007");
   $db->disconnect;

   $db->initialize is used to initialize the isin code list.
   Function "get_prices" first test if the isin code is initiasize, if not
it call the function "initialize".

=head2 Note

This module read the MASTER and the XMASTER file of you security directory
to get quotes, with a directory and a symbol as main parameters.
The MASTER file contain only the 255 first file (*.DAT) security of your
directory.
The XMASTER file all the others security (*.MWD) of your directory.

=head2 Configuration

NOTE: this module supercedes the module GT::DB::MetaStock. do not attempt
to use both.

You can indicate the directory which contains the MetaStock database
by setting the DB::metastock::directory configuration item.

=head2 new()

Create a new DB object used to retry quotes from a MetaStock database.

=cut
sub new {

    my $type = shift;
    my $class = ref($type) || $type;

    GT::Conf::default("DB::metastock::directory", "");

    my $self = { "directory" => GT::Conf::get("DB::metastock::directory"),
                 "codes" => undef};

    return bless $self, $class;
}

=head2 $db->disconnect

Disconnects from the database.

=cut
sub disconnect {
  my $self = shift;
}

=head2 $db->initialize

Construct the list of isin code.

=cut
sub initialize {
  my ($self,$directory) = @_;
  my $file;

  if (! defined $directory) {
    $directory = $self->{'directory'};
  }

  opendir (DIR,$directory) or die "Can't open the current directory $directory";

  foreach $file (readdir DIR) {

    # is a directory
    if (-d "$directory/$file") {

        if (($file ne ".") && ($file ne "..")) {

         $self->initialize("$directory/$file");
        }

    # is a file
    } elsif (-f "$directory/$file") {

      if ($file eq "MASTER") {

        $self->read_master($directory);

      } elsif ($file eq "XMASTER") {

        $self->read_xmaster($directory);
      }
    }
  }

  close(DIR);
}

=head2 $db->set_directory("/new/directory")

Indicate the directory containing your equity.

=cut
sub set_directory {
    my ($self, $directory) = @_;
    $self->{'directory'} = $directory;
}


=head2 $db->read_master

Read the MASTER file of your directory containing your equity.

=cut
sub read_master {

  my($self,$dir) = @_;

  undef my @nom_titre;
  undef my @code;
  my %enregistrement = ();
  my $file = $dir . "/MASTER";

  if (!(-e $file)) {
    return;
  }

  open(MASTER,"<$file") or die "Can't open file $file\n";
  binmode(MASTER);
  my $unpack = "S S A49";
  my $Index = 0;
  my ($NombreValeur,$Padding,$IndexValeurMax,$Record);
  read(MASTER,$Record,53) || die "Can't read a block in the file MASTER";

  ($NombreValeur,$IndexValeurMax,$Padding) = unpack($unpack,$Record);
  $unpack = "C s C C s A16 C A C C C C C C C C A S A14 C A C";
  my ($NumeroFichier,$TypeFichier,$TailleEnregistrement,
  $NumeroChamp,$NomValeur,$CTFlag,$DateDebut00,$DateDebut01,
  $DateDebut02,$DateDebut03,$DateFin00,$DateFin01,
  $DateFin02,$DateFin03,$Temps,$IDA,$ISIN,$Flag);

  while ($Index++ < $NombreValeur) {

    read(MASTER,$Record,53) || die "Can't read a block in the file MASTER";
    ($NumeroFichier,$TypeFichier,$TailleEnregistrement,
    $NumeroChamp,$Padding,$NomValeur,$Padding,$CTFlag,
    $DateDebut00,$DateDebut01,$DateDebut02,$DateDebut03,
    $DateFin00,$DateFin01,$DateFin02,$DateFin03,
    $Temps,$IDA,$ISIN,$Padding,$Flag,$Padding) = unpack($unpack,$Record);

    $enregistrement{'DIR'} = $dir;
    $enregistrement{'FILE'} = $NumeroFichier;
    $enregistrement{'TAILLE'} = $TailleEnregistrement;
    @code = split(/\x00/,$ISIN);
    @nom_titre = split(/\x00/,$NomValeur);
    $enregistrement{'ISIN'} = $code[0];
    $enregistrement{'NOM'} = $nom_titre[0];
    $enregistrement{'DATE_DEBUT'} = $self->convertFloat($DateDebut00,$DateDebut01,$DateDebut02,$DateDebut03);
    $enregistrement{'DATE_FIN'} = $self->convertFloat($DateFin00,$DateFin01,$DateFin02,$DateFin03);
    if (! exists ($self->{'codes'}{$ISIN})) {
    	$self->{'codes'}{$ISIN} = {%enregistrement};
    }
  }

  close(MASTER);
}


=head2 $db->read_xmaster

Read the XMASTER file of your directory containing your equity.

=cut
sub read_xmaster {

  my($self,$dir) = @_;

  my %enregistrement = ();
  my @nom_titre;
  my @code;
  my $file = $dir . "/XMASTER";

  if (!(-e $file)) {
    return;
  }

  open(XMASTER,"<$file") or die "Can't open file $file\n";
  binmode(XMASTER);
  my $unpack = "A10 C C A6 C C A130";
  my $Index = 0;
  my $NombreFichier = 0;
  my ($NombreFichierLow,$NombreFichierHigh,$NumeroFichierMaxLow,$NumeroFichierMaxHigh);
  my ($NumeroFichierLow,$NumeroFichierHigh,$NomValeur,$ISIN,$Padding,$Record);
  read(XMASTER,$Record,150) || die "Can't read a block in the file XMASTER";
  ($Padding,$NombreFichierLow,$NombreFichierHigh,$Padding,$NumeroFichierMaxLow,$NumeroFichierMaxHigh,$Padding) = unpack($unpack,$Record);
  $NombreFichier = $NombreFichierLow + ($NombreFichierHigh << 8);
  $unpack = "C A15 A22 A27 C C A83";

  while ($Index++ < $NombreFichier) {

     read(XMASTER,$Record,150) || die "Can't read a block in the file XMASTER";
     ($Padding,$ISIN,$NomValeur,$Padding,$NumeroFichierLow,$NumeroFichierHigh,$Padding) = unpack($unpack,$Record);

     $enregistrement{'DIR'} = $dir;
     $enregistrement{'FILE'} = $NumeroFichierLow + ($NumeroFichierHigh << 8);
     $enregistrement{'TAILLE'} = 0;
     @code = split(/\x00/,$ISIN);
     @nom_titre = split(/\x00/,$NomValeur);
     $enregistrement{'ISIN'} = $code[0];
     $enregistrement{'NOM'} = $nom_titre[0];

     $enregistrement{'DATE_DEBUT'} = 0;
     $enregistrement{'DATE_FIN'} = 0;
     if (! exists ($self->{'codes'}{$ISIN})) {
	     $self->{'codes'}{$enregistrement{'ISIN'}} = {%enregistrement};
     }    
  }

  close(XMASTER);
}

=head2 $db->find_isin($code)

Return the description for the symbol $code.

=cut
sub find_isin {

  my($self, $ISIN) = @_;
  my %retour = ();
  my $hash = \%{$self->{'codes'}};

  if (exists ($hash->{$ISIN})) {

     %retour = %{$hash->{$ISIN}};
  }

  return (\%retour);
}

=head2 $db->get_db_name($code)

Return the name for the symbol $code.

=cut
sub get_db_name {

  my($self, $isin) = @_;
  my $equity = $self->find_isin($isin);
  return $equity->{'NOM'};
}

=head2 $db->get_prices($code, $timeframe)

Returns a GT::Prices object containing all known prices for the symbol
$code.

=cut
sub get_prices {

  my($self, $isin, $timeframe) = @_;
  $timeframe = $DAY unless ($timeframe);
  die "Intraday support not implemented in DB::MetaStockReader" if ($timeframe < $DAY);
  return GT::Prices->new() if ($timeframe > $DAY);
  my $reg;
  my $file;
  my $unpack = "S S A24";
  my $Index = 0;
  undef my @tab;
  my $extension;
  my ($MaxRec,$LastRec,$Record);
  my ($Date00,$Date01,$Date02,$Date03,
  $Ouverture00,$Ouverture01,$Ouverture02,$Ouverture03,
  $PlusHaut00,$PlusHaut01,$PlusHaut02,$PlusHaut03,
  $PlusBas00,$PlusBas01,$PlusBas02,$PlusBas03,
  $Fermeture00,$Fermeture01,$Fermeture02,$Fermeture03,
  $Volume00,$Volume01,$Volume02,$Volume03,
  $OpInt00,$OpInt01,$OpInt02,$OpInt03);

  my ($open, $high, $low, $close, $volume, $date, $time);
  my ($year, $month, $day);

  if (!defined $self->{'codes'}) {

    $self->initialize($self->{'directory'});
  }

  my $prices = GT::Prices->new();
  $prices->set_timeframe($timeframe);

  $reg = $self->find_isin($isin);

  if (!defined $reg->{'FILE'}) {
     die ("Can't find $isin security\n");
     exit;
  }

  if ($reg->{'FILE'} > 255) {
     $extension = ".MWD";
  } else {
     $extension = ".DAT";
  }

  $file = $reg->{'DIR'} . "/F" .$reg->{'FILE'} . $extension;

  open(DATA,"<$file") or die "Can't open the file $file\n";
  binmode(DATA);

  read(DATA,$Record,28) == 28 || die "Can't read a block";
  ($MaxRec,$LastRec) = unpack($unpack,$Record);
  $unpack = "C C C C C C C C C C C C C C C C C C C C C C C C C C C C";

  while ($Index < $LastRec-1) {

    read(DATA,$Record,28) == 28 || die "Can't read a block";
    ($Date00,$Date01,$Date02,$Date03,
    $Ouverture00,$Ouverture01,$Ouverture02,$Ouverture03,
    $PlusHaut00,$PlusHaut01,$PlusHaut02,$PlusHaut03,
    $PlusBas00,$PlusBas01,$PlusBas02,$PlusBas03,
    $Fermeture00,$Fermeture01,$Fermeture02,$Fermeture03,
    $Volume00,$Volume01,$Volume02,$Volume03,
    $OpInt00,$OpInt01,$OpInt02,$OpInt03) = unpack($unpack,$Record);

    $date = $self->convertFloat($Date00,$Date01,$Date02,$Date03);
    $open = $self->convertFloat($Ouverture00,$Ouverture01,$Ouverture02,$Ouverture03);
    $high = $self->convertFloat($PlusHaut00,$PlusHaut01,$PlusHaut02,$PlusHaut03);
    $low = $self->convertFloat($PlusBas00,$PlusBas01,$PlusBas02,$PlusBas03);
    $close = $self->convertFloat($Fermeture00,$Fermeture01,$Fermeture02,$Fermeture03);
    $volume = $self->convertFloat($Volume00,$Volume01,$Volume02,$Volume03);
    $date += 19000000;
    $date =~ /^(\d{4})(\d{2})(\d{2})/;
    $date = $1 . "-" . $2 . "-" .$3;
    $prices->add_prices([ $open, $high, $low, $close, $volume, $date ]);
    $Index++;
  }

  close(DATA);

  return $prices;
}


=head2 $db->puissance($value00,$value01,$value02,$value03)

Convert a MSBIN format to a float perl format (4 bytes).
It convert first to a IEEE float format (4 bytes).

=cut
sub convertFloat {

  my($self,$value00,$value01,$value02,$value03) = @_;

  my $signe = 0x00;
  my $exp = 0x00;
  my $resultat = 0;
  my $virgule = 0;

  my $resultat00 = $value00;
  my $resultat01 = $value01;
  my $resultat02 = 0x00;
  my $resultat03 = 0x00;

  $signe = $value02 & 0x80;
  $resultat03 |= $signe;
  $exp = $value03 - 2;
  $resultat03 |= ($exp >> 1) & 0xff;
  $resultat02 |= ($exp << 7) & 0xff;
  $resultat02 |= ($value02 & 0x7F);
  $resultat = pack("CCCC",$resultat00,$resultat01,$resultat02,$resultat03);
  $resultat = unpack("f",$resultat);
  return $resultat;
}

=head2 $db->get_last_prices($code, $limit, $timeframe)

NOT YET SUPPORTED for MetaStockReader module.

Returns a GT::Prices object containing the $limit last known prices for
the symbol $code.

=cut
sub get_last_prices {
    my ($self, $code, $limit, $timeframe) = @_;

    return get_prices($self, $code, $timeframe) if ($limit==-1);
    die "get_last_prices not yet supported with metastock database\n";
}

1;
=back

=head1 COPYRIGHT

Copyright 2003-2005 Tournedouet Yannick.

=cut

