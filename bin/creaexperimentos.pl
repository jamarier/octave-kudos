#!/usr/bin/perl
# Projecto kudos de octave 
# (C) 2013 Javier M. Mora-Merchan et al.
# BSD 3-Clause License

use Modern::Perl;
use IO::All;

# definiendo fichero de entrada y de salida
my ($nombrein) = (shift);
my $nombreout = $nombrein;
$nombreout =~ s/\.expm$/.m/;

# verificando que no vamos a borrar un fichero no apropiado
die("Fichero de entrada no tiene la extensión .expm solicitada") if $nombrein eq $nombreout;

# plantilla
my $plantilla= <<'END';
[[Objetivo]]%
[[Autoria]]%
[[Requisito]]%
[[Glosario]]%

%% Inicio del código

[[Declaracion]]
if (verificando==0)
  % código de la explicación

[[Inicializacion]]

  % mostrando el texto informativo
  disp([ ...
[[Texto]]...
       ]);
else
  % código necesario para efectuar la validación
[[Prevalidacion]]
  % validamos si saltamos al siguiente experimento si procede
  if( 1 ... % el uno simplifica la generación de la validación
 [[Validacion]]  )
    siguiente
  end
end
END

# campos
my $autoria = '';
my $titulo ='';
my $objetivo='';
my $requisito={};
my $glosario={};
my $texto='';
my $prevalidacion='';
my $validacion='';
my $declaracion='';
my $inicializacion='';
my $textovalidacion = '';

# lectura del fichero de entrada uno a uno
my $io = io $nombrein;

my $t = ' ' x 10; # sangrado
while (my $line = $io->getline) {
  chomp $line;

  if ($line =~ '') { $texto .= $t."char(10),... \n" }
  elsif ($line =~ /^\s*#/)
      {
	# es un comentario y se ignora la línea
      }
  elsif ($line =~ /^\s*NOMBRE:\s*(.*)$/)
      { $titulo = $1;
	my $offset = -1 * contandoacentos($titulo);
	$texto .= $t."cabeceraexperimento('$titulo',$offset),...\n"}
  elsif ($line =~ /^\s*AUTOR:\s*(.*)$/)
      { $autoria .= "% Experimento realizado por $1\n" }
  elsif ($line =~ /^\s*OBJETIVO:\s*(.*)$/)
      { $objetivo = "%%% $1\n" }
  elsif ($line =~ /^\s*REQUISITO:\s*(.*)$/)
      { $requisito = cargacamposlineal($requisito,$1); }
  elsif ($line =~ /^\s*GLOSARIO:\s*(.*)$/)
      { $glosario = cargacamposlineal($glosario,$1); }
  elsif ($line =~ /^\s*EJEMPLO-IN:\s*(.*)$/)
      { my $esc = escapetexto($1);$texto .= $t."banderaejemplo('> $esc'),char(10),...\n" }
  elsif ($line =~ /^\s*EJEMPLO-OUT:\s*(.*)$/)
      { $texto .= $t."banderaejemplo(['ans = ',num2str($1)]),char(10),...\n" }
  elsif ($line =~ /^\s*EJEMPLO-OUT\*:\s*(.*)$/)
      { my $esc = escapetexto($1);$texto .= $t."banderaejemplo($esc),char(10),...\n" }
  elsif ($line =~ /^\s*EJEMPLO-INOUT:\s*(.*)$/)
      { my $esc = escapetexto($1);
        $texto .= $t."banderaejemplo('> $esc'),char(10),...\n";
	      $texto .= $t."banderaejemplo(['ans = ',num2str($esc)]),char(10),...\n" }
  elsif ($line =~ /^\s*CODIGO:\s*(.*)$/)
      { my $esc = escapetexto($1);
        $texto .= $t."'>> $esc',...\n";
        $texto .= "  ]);\n";
        $texto .= "  $esc\n";
        $texto .= "  disp([ ...\n";
      }
  elsif ($line =~ /^\s*TAREA:?\s*$/)
      { $texto .= $t."cabeceratarea,...\n" }
  elsif ($line =~ /^\s*VARIABLE:\s*(\w+)\s*,\s*(.*)\s*$/)
      { 
	      $declaracion .= "global $1;\n";
	      $inicializacion .= "  $1=$2;\n";
      }
  elsif ($line =~ /^\s*PREVERIFICACION:\s*(.*)\s*$/)
      { 
	      $prevalidacion .= $t."$1\n";
      }
  elsif ($line =~ /^\s*VERIFICACION:\s*(.*)\s*CONDICION:?\s*(.*)\s*$/)
      {
        my $esc = escapetexto($1);
        say "verificando $esc";
	      $validacion .= "$t"."&& verificarTrue('$esc',$2) ...\n";
	      $textovalidacion = $t."'Cuando haya terminado, use f:verificar ".
	        "para comprobar si la tarea se realizó correctamente.',char(10)";
      }
  elsif ($line =~ /^\s*SINVERIFICACION:?\s*$/)
      { $textovalidacion = $t."'Cuando haya terminado, use f:siguiente ".
	        "para avanzar hasta el próximo experimento.',char(10)";
	$validacion.= "$t"."&& noVerificacion ...\n" }
  else
      { $line = escapetexto($line);$texto .= "$t'$line',char(10),...\n" }
}

# añadimos el texto de validación adecuado
$texto .= $t."char(10),...\n$textovalidacion";

$objetivo = $objetivo || "%%% $titulo\n";

if (!$autoria) {
  $autoria = "%% Experimento realizado por Javier M. Mora-Merchan et al.\n";
}
$autoria = "%% Sistema Kudos elaborado por Javier M. Mora-Merchan et al.\n".$autoria.
    "%% Projecto kudos de octave\n".
    "%% (C) 2013 Bajo licencia BSD 3-Clause License\n"
;

$declaracion = "% declaración de variables\n".$declaracion;
$inicializacion = "  % inicialización de variables\n".$inicializacion;

# glosario 
while ($texto =~ /(f|g):(\w+)/g) {
  $glosario->{$2} = 1;
}

# rellenando la plantilla
$plantilla = rellenaplantilla($plantilla,
            'Autoria' => $autoria,
			      'Objetivo' => $objetivo,
			      'Requisito' => escribecamposlineal("% Requisito: ",$requisito),
			      'Glosario' => escribecamposlineal("% Glosario: ",$glosario),
			      'Texto' => $texto,
			      'Prevalidacion' => $prevalidacion,
			      'Validacion' => $validacion,
			      'Declaracion' => $declaracion,
			      'Inicializacion' => $inicializacion);

$plantilla =~ s/(f|q):(\w+)/"$2"/g;
$plantilla =~ s/(g):(\w+)/$2/g;

# salida
$plantilla > io($nombreout);

sub escapetexto {
  my ($text) = (shift);
  if (substr($text,0,1) ne "'") {$text =~ s/'/''/g;}
  return $text;
}

sub rellenaplantilla {
  my ($plantilla,%campos) = (shift,@_);

  foreach my $campo (keys(%campos)) {
    $plantilla = rellenacampo($plantilla,$campo,$campos{$campo});
  }
  return $plantilla;
}

sub rellenacampo {
  my ($plantilla,$campo,$contenido) = (shift,shift,shift);
  $plantilla =~ s/\[\[$campo]]/$contenido/g;
  return $plantilla;
}

sub contandoacentos {
  my ($texto) = (shift);
  my $copiatexto = $texto;
  my $cuenta = $copiatexto =~ s/á|é|í|ó|ú/1/ig;
  return $cuenta;
}

sub cargacamposlineal {
  my ($campos,$texto) = (shift,shift);

  my @words = split(/,/,$texto);

  foreach my $word (@words) {
    $word =~ s/^\s+|\s+$//g;
    if ($word) {
      $campos->{$word} = 1;
    }
  }

  return $campos 
}

sub escribecamposlineal {
  my ($cabecera,$campos) = (shift,shift);
  
  if (keys %$campos) {
    return $cabecera.join(", ",map { $_ } keys %$campos)."\n";
  }
  else {
    return '';
  }
}
