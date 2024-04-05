#!/usr/bin/perl
# Projecto kudos de octave 
# (C) 2013 Javier M. Mora-Merchan et al.
# BSD 3-Clause License

use Modern::Perl;
use IO::All;
use Data::Dumper;
use Storable qw(dclone);
use List::Util qw( max );

my $nombresalida= "listaexperimentos.m";
my $indicesalida= "indice.m";
my $pistassalida= "pista.m";
my $glosarsalida= "glosario.m";

my @directorios = @ARGV;

my ($bloques,$experimentos) = loadExperimentos(@directorios);
creagrafo("casos.dot",$experimentos);
my $orden = [ orden1($experimentos)]; unshift(@{$orden->[0]},'.');
#my $orden = orden2($bloques,$experimentos);
generaIndices($orden,$experimentos);

sub loadExperimentos {
  my @directorios = @_;

  my ($bloques,$experimentos) = cargaExperimentos(@directorios);
  dependenciasExisten($experimentos);

  # Creación de longitud máxima
  # inicialización de las variables de orden:
  foreach my $experimento (keys %$experimentos) {
      $experimentos->{$experimento}{'longmax'} = 0;
      $experimentos->{$experimento}{'nivel'} = 0;
      $experimentos->{$experimento}{'hijos'} = [];
  }
  foreach my $experimento (keys %$experimentos) {
    foreach my $dependencias_bloque (@{$experimentos->{$experimento}{'dependencias'}}) {
      my $dependencia = $dependencias_bloque->[0];
      push(@{$experimentos->{$dependencia}{'hijos'}}, $experimento)
    }
  }
  # construcción de hijos, nivel y maxlongitud
  my $cambios= 1==1;
  while ($cambios) {
    $cambios=0;
    foreach my $experimento (keys %$experimentos) {
      #calculo del nuevo nivel
      if (@{$experimentos->{$experimento}{'dependencias'}}) {
        my $maxnivel = max 
          map { $experimentos->{$_->[0]}{'nivel'} }
          @{$experimentos->{$experimento}{'dependencias'}}
        ;
        if ($experimentos->{$experimento}{'nivel'} < $maxnivel+1) {
          $experimentos->{$experimento}{'nivel'} = $maxnivel+1;
          $cambios= 1==1;
        }
      }
      #calculo de la nueva longmax
      if (@{$experimentos->{$experimento}{'hijos'}}) {
        my $longmax = max 
          map { $experimentos->{$_}{'longmax'} }
          @{$experimentos->{$experimento}{'hijos'}}
        ;
        if ($experimentos->{$experimento}{'longmax'} < $longmax+1) {
          $experimentos->{$experimento}{'longmax'} = $longmax+1;
          $cambios= 1==1;
        }
      }
    }
  }
  #say Dumper({"experimentos"=>$experimentos});

  return $bloques,$experimentos
}

sub creagrafo {
  my ($file,$experimentos) = (shift,shift);
  my $texto =<<END;
digraph {    
  edge [dir="back"]; /* note the change to this line */
END

  for my $experimento (keys %$experimentos) {
    my @hijos = @{$experimentos->{$experimento}{'hijos'}};
    @hijos = ("$experimento [style=invis]") unless @hijos;

    for my $hijo (@hijos) {
      $texto .= "  $experimento -> $hijo\n"
    }

  }
  $texto.=<<END;
}
END

  $texto > io($file);
}


#ordenación intentando cierta coherencia
sub orden1 {
  my ($experimentos) = (shift);
  
  # siguientes
  my %usados;
  my @orden;

  # primeros elementos bootstarp
  my @siguientes = 
    sort { $b->[2] <=> $a->[2]}
    map { [$_, $experimentos->{$_}{'nivel'}, $experimentos->{$_}{'longmax'}] }
    grep { $experimentos->{$_}{'nivel'} == 0 }
    keys %$experimentos;

  while (@siguientes) {
    my ($actual,$nivel,$longmax) = @{shift @siguientes};
    
    next if exists($usados{$actual}); #ignorar si ya está
    # ignorar si no tiene todas las dependencias
    #say Dumper("actual",{$actual=>$experimentos->{$actual}});
    my $sin_dependencias=1==0;
    for my $dependencia (@{$experimentos->{$actual}{'dependencias'}}) {
      my $nombre = $dependencia->[0];
      unless (exists($usados{$nombre})) {
        $sin_dependencias= 1==1;
        last
      }
    }
    next if $sin_dependencias;

    #añadiendo nuevo entrada
    push(@orden,$actual);
    $usados{$actual} = 1;

    #incorporando los siguientes
    my @protosiguientes = 
      sort { $a->[1] <=> $b->[1] || $b->[2] <=> $a->[2] }
      map { [$_, $experimentos->{$_}{'nivel'}, $experimentos->{$_}{'longmax'}] }
      @{$experimentos->{$actual}{'hijos'}};

    unshift(@siguientes, @protosiguientes);

    #say Dumper({
    #  "actual"=>$actual,
    #  "nivel"=>$nivel,
    #  "longmax"=>$longmax,
    #  "protosiguientes"=> \@protosiguientes,
    #  "siguientes"=> \@siguientes,
    #  "orden"=> \@orden,
    #});

  }
  say("orden: @orden");
  say("num elementos orden ", $#orden+1);
  say("num elementos usados ", 0 + keys %usados);
  say("num elementos disponibles ", 0 + keys %$experimentos);
  foreach my $topic (keys %$experimentos) {
    next if exists($usados{$topic});
    say("$topic no está en el índice");
  }

  return \@orden
}

# este orden es más naive, entre todos los que no tienen padre (porque ya se ha usado)
# escoge uno al azar
sub orden2 {
  my ($bloques,$experimentos) = (shift,shift);

  my @orden;
  for my $bloque (@$bloques) {
    say("ordenando bloque: $bloque");
    my @bloque = ($bloque);
    my $prelacion = experimentos_en_bloque($experimentos,$bloque);
    push(@bloque, @{ordena_prelacion($prelacion)});
    push(@orden, \@bloque);
  }

  return \@orden;
}



# Ordena prelaciones
sub ordena_prelacion {
  my ($prelaciones) = (shift);

  my @raices = buscaraices($prelaciones);

  # say Dumper("prelaciones" => \%prelaciones,
  #            "raices" => \@raices);

  if (@raices == 0) { die "No hay ningún elemento raiz" }
  if (@raices > 1) {  say "SIN PADRE: $_" foreach @raices; }


  # construyendo el orden final
  my @orden;
  while(@raices) {
    push @orden, @raices;
    # eliminamos las prelaciones de las raices seleccionadas
    delete $prelaciones->{$_} foreach @raices;
    # eliminamos el requisito de raices a las prelaciones restantes
    foreach my $exp (keys %$prelaciones) {
      foreach my $raiz (@raices) {
        $prelaciones->{$exp} = [grep {$_ ne $raiz} @{$prelaciones->{$exp}} ]
      }
    }
    @raices = buscaraices($prelaciones);

    # say Dumper("orden" => \@orden,
    #            "prelaciones" => \%prelaciones,
    #            "raices" => \@raices); 
  }

  if (keys %$prelaciones > 0) {
    say Dumper("prelacion" => $prelaciones);
    die "Circularidad no resuelta";
  }

  return \@orden;
}

# Obtiene los experimentos en cierto bloque
sub experimentos_en_bloque {
  my ($experimentos,$bloque) = (shift,shift);

  my %experimentos_en_bloque; 

  for my $experimento (keys %$experimentos) {
    next if $experimentos->{$experimento}{"bloque"} ne $bloque;
    $experimentos_en_bloque{$experimento} = [];

    for my $dependencias (@{$experimentos->{$experimento}{"dependencias"}}) {
      my $dep_bloque = $dependencias->[1];
      next if $bloque ne $dep_bloque;
      push(@{$experimentos_en_bloque{$experimento}},$dependencias->[0]);
    }
  }

  return \%experimentos_en_bloque;
}

# Verificar que las dependencias existen
sub dependenciasExisten {
  my ($experimentos) = (shift);

  keys %$experimentos;
  while(my($nombre, $hash) = each %$experimentos){
    my $dependencias = $hash->{"dependencias"};
    for my $dependencias (@$dependencias) {
      my $nombre_dependencia = $dependencias->[0];
      my $nombre_bloque = $dependencias->[1];

      if (!exists($experimentos->{$nombre_dependencia})) {
        die("La dependencia de $hash->{'source'}: <$nombre_dependencia> no existe.")
      }
      if ($experimentos->{$nombre_dependencia}{"bloque"} ne $nombre_bloque) {
        die("La dependencia de $hash->{'source'}: <$nombre_dependencia> tiene el bloque erróneo.")
      }
    }
  }
}

sub cargaExperimentos {
  my @directorios = @_;
  my @bloques;
  my %experimentos;

  foreach my $dir (@directorios) {
    say "Directorio $dir";
    my $bloque = leeBloque($dir);
    push @bloques,$bloque;
    foreach my $file (io->dir($dir)->all) {
      next if $file !~ m!(.*)/(.*)\.expm$!;
      my $experiment_dir = $1;
      my $name = $2;

      # check if a filename is repeated in db
      if (exists($experimentos{$name})) {
        die "EXPERIMENTO DUPLICADO: <$experiment_dir/$name.expm> and ".
            "<$experimentos{$name}{'source'}>"; 
      }

      # lee el script
      say("file $file");
      my $script = leeScriptM($file);

      # lee las dependencias
      my $dependencias = leeDependencias($bloque,$script);

      # lee los términos del glosario
      my $glosario = leeGlosario($script);

      # lee el título
      my $titulo = leeTitulo($script);


      $experimentos{$name}={
        "source"=>"$file",
        "bloque"=>$bloque,
        "dependencias"=>$dependencias,
        "titulo"=>$titulo,
        "glosario"=>$glosario,
      };
    }
  }

  return \@bloques,\%experimentos
}

## extrae el Bloque de la descripción del directorio 
sub leeBloque {
  my ($directorio) = (shift);
  $directorio =~ m!^.*/(.*?)/?$!;
  my $bloque = $1;
  #say Dumper("bloque"=>$bloque);
  
  return $bloque
}

sub leeScriptM {
  my ($file) = (shift);
  my $scriptfile = $file;
  $scriptfile =~ s/\.expm$/.m/;

  my $text = io($scriptfile)->all;
  return $text
}

## lee campos en una línea con cabecera
sub leeCampos {
  my ($cabecera,$texto) = (shift,shift);

  my @campos;
  my $pat = qr/^%\s+$cabecera:\s*(.*)$/m;
  while ($texto =~ /$pat/g) {
    my @campos_en_linea = 
      grep {/\S/}
      map { s/^\s+|\s+$//g; $_ } 
      split(/,/,$1);
    push (@campos,@campos_en_linea);
  }

  return \@campos
}

## lee las prelaciones de los ficheros de un directorio dado.
sub leeDependencias {
  my ($bloque,$texto) = (shift,shift);

  my @prelacionesleidas;
  for my $prelacion (@{leeCampos("Requisito",$texto)}) {
    if ($prelacion =~ m/^(.*):(.*)$/) {
      push(@prelacionesleidas,[$2,$1])
    }
    else {
      push(@prelacionesleidas,[$prelacion,$bloque]);
    }
  }
  return \@prelacionesleidas;
}

## lee el glosario.
sub leeGlosario {
  my ($texto) = (shift);

  return leeCampos("Glosario",$texto);
}

## Lee el título de cada experimento
sub leeTitulo {
  my ($texto) = (shift);

  my @titulo;
  while ($texto =~ /^%%%\s*(.*)$/mg) {
    my $titulo = $1;
    #say("titulo <$titulo>");
    $titulo =~ s/^\s+|\s+$//g;
    push(@titulo,$titulo);
  }

  return join(" ",@titulo)
}

sub buscaraices {
  my ($prelaciones) = (shift);
  my @raices;

  foreach my $experimento (keys %$prelaciones) {
    push @raices, $experimento unless @{$prelaciones->{$experimento}};
  }

  return @raices;
}

sub generaIndiceExperimentos {
  my ($orden, $experimentos) = (shift, shift);

  # procesando cada entrada en el índice
  my $itabsoluto=0;
  foreach my $bloque (@$orden) {
    say("generando indice de ",$bloque->[0]);

    foreach my $funcion (@$bloque[1..$#{$bloque}]) {
      my $funcion_info = $experimentos->{$funcion};
      $funcion_info->{"indice"} = $itabsoluto;
      $funcion_info->{"textoindice"} = sprintf("disp(' %3d     %s') %% %s:%s\n",
                              $itabsoluto,
                              $funcion_info->{"titulo"},
                              $funcion_info->{"bloque"},
                              $funcion);
      $itabsoluto++;

    }

  }

  return $experimentos
}

sub generaFicheroIndice {
  my ($orden, $experimentos) = (shift, shift);

  my $indicetexto = <<END ;
%%% Indice de experimentos
%
% Sistema de Kudos aprendizaje de octave 
% fichero generado automáticamente, no tocar

%%% Indice de experimentos
% Lista los experimentos disponibles:

END

  # procesando cada entrada en el índice
  foreach my $bloque (@$orden) {
    $indicetexto.= "%% bloque: $bloque->[0]\n";

    foreach my $funcion (@$bloque[1..$#{$bloque}]) {
      $indicetexto .= $experimentos->{$funcion}{"textoindice"};
    }

    #fin del bloque
    $indicetexto.= "\n"; 
  }

  # finales del fichero
  $indicetexto .= <<END;

disp('')
disp('Para ir a un experimento determinado usar el comando irexperimento')
END

  return $indicetexto
}

sub generaDispacher {
  my ($orden,$experimentos) = (shift,shift);

  my $listatexto = <<END ;
%%% Dispatcher de experimentos
%
% fichero generado automáticamente, no tocar


experimentos = {
END

  # procesando cada entrada en el índice
  foreach my $bloque (@$orden) {
    $listatexto.= " % bloque: $bloque->[0]\n";

    foreach my $funcion (@$bloque[1..$#{$bloque}]) {
      $listatexto .= " '$funcion'; ...\n";
    }
    $listatexto .= " ...\n";
  }

  $listatexto .= <<"END";
};

if (numexp<0 || length(experimentos)<=numexp)
  disp(['El experimento ',int2str(numexp),' no está definido aún.']);
else
  feval(experimentos{numexp+1});
endif

END

  return $listatexto
}

sub generaPistas {
  my ($orden,$experimentos) = (shift,shift);

  my $pistatexto = <<END ;
%%% Proporciona pistas a experimentos
%
% fichero generado automáticamente, no tocar

msg = ['El presente experimento (',int2str(numexp),...
       ') se basa en conocimientos'...
       ' de los experimentos:', char(10), ...
       char(10), ...
       ' NUM     TITULO'];

msg2 = [char(10), ...
        'Usa: "irexperimento(NUM)" para repasar alguno de dichos conocimientos', char(10),...
        'y posteriormente usa "irexperimento(',int2str(numexp),')" para volver a este.'];

if numexp == -1
END

  # procesando cada entrada en el índice
  foreach my $bloque (@$orden) {
    $pistatexto.= 
      "\n % %%%%%%%%%%%%%%%%%%%%%%%%".
      "\n % bloque: $bloque->[0]".
      "\n % %%%%%%%%%%%%%%%%%%%%%%%%".
      "\n\n";

    foreach my $funcion (@$bloque[1..$#{$bloque}]) {
      my %funcion_info = %{$experimentos->{$funcion}};

      # pistas
      $pistatexto .= "elseif numexp == $funcion_info{'indice'} % $funcion\n";
      my @dependencias = 
          map { $_->[1]}
          sort { $a->[0] <=> $b->[0]}
          map {[$experimentos->{$_}{'indice'},
                $experimentos->{$_}{'textoindice'}] }
          map {$_->[0]} 
          @{$funcion_info{"dependencias"}};
      if (@dependencias) {
        $pistatexto .= "  disp(msg)\n";
        $pistatexto .= "  $_" for @dependencias;
        $pistatexto .= "  disp(msg2)\n\n";
      } else {
        $pistatexto .= "  disp('Lo siento no hay pistas para este experimento')\n\n";
      }

    }
  }

  $pistatexto .= <<"END";
else
  disp(['El experimento ', int2str(numexp), ' no está definido aún.']);
endif

END

  return $pistatexto
}

sub generaGlosario {
  my ($experimentos) = (shift);

  # creación termino -> [funciones]
  my %glosario_funcion;
  foreach my $experimento (keys %$experimentos) {
    my %info = %{$experimentos->{$experimento}};
    foreach my $termino (@{$info{"glosario"}}) {
      $glosario_funcion{$termino} = [] if !exists($glosario_funcion{$termino});
      push(@{$glosario_funcion{$termino}},$experimento);
    }
  }

  my %glosario = 
    map {
      my $termino = $_;
      my @contenido = 
        map { $_->[1]}
        sort { $a->[0] <=> $b->[0] }
        map {
          [
            $experimentos->{$_}{'indice'},
            $experimentos->{$_}{'textoindice'}
          ]
        }
        @{$glosario_funcion{$termino}};
      $termino => \@contenido
    }
    keys %glosario_funcion;
  

  return \%glosario
}

sub generaFicheroGlosario {
  my ($experimentos) = (shift);

  my $glosartexto = <<END ;
%%% Glosario de términos, muestra o busca
%
% fichero generado automáticamente, no tocar

function glosario(varargin)

END

  # procesado de cada elemento del glosario
  my $glosario = generaGlosario($experimentos);

  my @terminos = sort keys %$glosario;

  # glosario llamado sin opciones, se muestran todos 
  # los términos
  $glosartexto .= <<END;
  if length(varargin)==0
    disp('')
    disp('Los términos por los que se puede buscar son:')
    disp('')
    disp([${\("'".join("', char(9), '",@terminos)."'")}]);

END

  # glosario llamado con una opción, se muestra
  foreach my $termino (@terminos) {
    my $entradas = "    ".join("    ",@{$glosario->{$termino}});
    $glosartexto .= <<END;
  elseif strcmp(varargin{1},'$termino')
    disp('');
    disp('Término "$termino":');
    disp('');
    disp(' NUM     TITULO');
$entradas%
    
END
  }

  # último caso, el termino no existe
  $glosartexto .= <<"END";
  else
    disp(['El término solicitado no está en el glosario.', char(10),...
          'Escribe "glosario" para ver los términos definidos.'])
  endif
endfunction

END

  return $glosartexto;

}

sub generaIndices {
  my ($orden,$experimentos) = (shift,shift);

  #cabecera común
  my $cabecera_comun = <<END;
%%% Projecto kudos de octave
%%% (C) 2023 Javier M. Mora-Merchan
%%% Bajo licencia GPL v.3 o posterior
%%%
END
  chomp($cabecera_comun);

  # genera indice (posiciones y textos)
  $experimentos = generaIndiceExperimentos($orden,$experimentos);
  #say Dumper("exp"=>$experimentos);

  # indice experimentos
  my $indicetexto = $cabecera_comun;
  $indicetexto .= generaFicheroIndice($orden,$experimentos);
  $indicetexto > io($indicesalida);

  # dispatcher de experimentos
  my $listatexto = $cabecera_comun;
  $listatexto .= generaDispacher($orden,$experimentos);
  $listatexto > io($nombresalida);

  # generación de pistas
  my $pistatexto = $cabecera_comun;
  $pistatexto .= generaPistas($orden,$experimentos);
  $pistatexto > io($pistassalida);

  # generacion del glosario
  my $glosartexto = $cabecera_comun;
  $glosartexto .= generaFicheroGlosario($experimentos);
  $glosartexto > io($glosarsalida);

}

