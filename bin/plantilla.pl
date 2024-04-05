#!/usr/bin/perl
# Projecto kudos de octave 
# (C) 2013 Javier M. Mora-Merchan et al.
# BSD 3-Clause License

use Modern::Perl;
use IO::All;

my $plantilla = (shift @ARGV);

if (! (defined $plantilla)) {
  die ("Usage: plantilla octave|programacion|psm");
}

say "Plantilla: $plantilla";

if ($plantilla eq "octave") {
  my $datos = reunedatos();

  cabecera($datos,"exp_ayuda");
  $datos->{fichero} << "TAREA\n";
  $datos->{fichero} << "\n";
  pie($datos);
  
  exit 0;
};

if ($plantilla eq "programacion") {
  my $datos = reunedatos();

  cabecera($datos,"exp_programacion");
  $datos->{fichero} << "\n";
  pie($datos);

  exit 0;
}

if ($plantilla eq "psm") {
  my $datos = reunedatos();

  cabecera($datos,"exp_psm");
  $datos->{fichero} << "\n";
  pie($datos);

  exit 0;
}

die ("Usage: plantilla octave|programacion|psm");

sub reunedatos {
  my %datos;
  $datos{fichero} = nombrefichero();
  $datos{titulo} = nombreexperimento();
  $datos{objetivo} = objetivo();

  return \%datos;
}

sub cabecera {
  my ($datos,$requisito) = (shift,shift);

  $datos->{fichero} < "NOMBRE: $datos->{titulo}\n";

  if ($datos->{objetivo} ne '') {
    $datos->{fichero} << "OBJETIVO: $datos->{objetivo}\n";
  }

  $datos->{fichero} << "REQUISITO: $requisito\n";
  $datos->{fichero} << "\n"; #fin de la cabecera.
}

sub pie {
  my ($datos) = (shift);

  $datos->{fichero} << "SINVERIFICACION";

}

sub nombrefichero {
  print "Nombre del fichero: ";
  my $nombre = <>;
  chomp $nombre;
  $nombre =~ s/\s/_/g;
  $nombre = "exp_$nombre.expm";

  if (-e $nombre) {
    die "El fichero $nombre ya existe";
  }
  
  return io($nombre);
}

sub nombreexperimento {
  print "Nombre del experimento: ";
  my $nombre = <>;
  chomp $nombre;

  if ($nombre eq '') {
    die "El experimento ha de tener un nombre";
  }
  
  return $nombre;
}

sub objetivo {
  print "Objetivo (o vacio): ";
  my $objetivo= <>;
  chomp $objetivo;
  return $objetivo;
}
