#!/usr/bin/perl

use Modern::Perl;
use IO::All;
use Data::Dumper;
use Carp;
#use experimental 'smartmatch';

my %comandos= (
               help        => \&comando_help,
               hel         => \&comando_help,
               he          => \&comando_help,
               h           => \&comando_help,
               dependencia => \&comando_dependencia,
               dependenci  => \&comando_dependencia,
               dependenc   => \&comando_dependencia,
               dependen    => \&comando_dependencia,
               depende     => \&comando_dependencia,
               depend      => \&comando_dependencia,
               depen       => \&comando_dependencia,
               depe        => \&comando_dependencia,
               dep         => \&comando_dependencia,
               de          => \&comando_dependencia,
               d           => \&comando_dependencia,
               intercala   => \&comando_intercala,
               intercal    => \&comando_intercala,
               interca     => \&comando_intercala,
               interc      => \&comando_intercala,
               inter       => \&comando_intercala,
               inte        => \&comando_intercala,
               int         => \&comando_intercala,
               in          => \&comando_intercala,
               i           => \&comando_intercala,
               base => \&comando_base,
               bas  => \&comando_base,
               ba   => \&comando_base,
               b    => \&comando_base,
               tope => \&comando_tope,
               top  => \&comando_tope,
               to   => \&comando_tope,
               t    => \&comando_tope,
               show => \&comando_show,
               renombra => \&comando_renombra,
               borradependencias => \&comando_borradependencia,
              );

my $dirbase = extraer_dir_experimentos();
my %ficheros = buscar_ficheros($dirbase);
#mostrar_ficheros(%ficheros);


#############################################
# Gestión de ficheros

sub extraer_dir_experimentos {
  my $dirbase = $0;
  $dirbase =~ s!(.*)/.*!$1!;
  return "$dirbase/../experimentos/"
}

sub add_fichero {
  my ($fichero, %ficheros) = (@_);

  #ignoramos extension errónea
  return %ficheros unless $fichero=~/.*\.expm$/;

  $fichero =~ m!^.*/(.*)/(.*).expm!;
  my $nombre = $2;
  my $bloque = $1 eq 'experimentos' ? '.' : $1;
 
  $ficheros{$nombre} = {'bloque'=>$bloque, 'src'=>$fichero};

  return %ficheros
}

sub buscar_ficheros {
  my ($dirbase) = (shift);

  my %ficheros;

  %ficheros = add_fichero($_,%ficheros) for io($dirbase)->All;       

  return %ficheros;
}

# función de depuración para mostrar los experimentos disponibles
sub mostrar_ficheros {
  my (%ficheros) = (@_);
  foreach my $fichero (sort keys %ficheros) {
    print("$fichero: ");
    foreach my $key (keys %{$ficheros{$fichero}}) {
      print("$key->$ficheros{$fichero}{$key}. ")
    } 
  print("\n");
  }
  say('');
}

sub extrae_nombre {
  my ($texto) = (shift);

  $texto =~ s!(.*(/|:))?(.*?)(\.expm)?$!$3!;

  return $texto
}

sub extrae_bloque {
  my ($texto) = (shift);
  my $nombre = extrae_nombre($texto);

  if (exists($ficheros{$nombre})) {
    return $ficheros{$nombre}{'bloque'}
  } else {
    die("El fichero con nombre <$nombre> no existe.")
  }
}

sub extrae_bloquenombre {
  my ($texto,$referencia) = (shift,shift);
  my $bloque_texto = extrae_bloque($texto);
  my $bloque_referencia = extrae_bloque($referencia);

  if ($bloque_texto eq $bloque_referencia) {
    return extrae_nombre($texto);
  } else {
    return "$bloque_texto:".extrae_nombre($texto);
  }

}

sub extrae_src {
  my ($texto) = (shift);
  my $nombre = extrae_nombre($texto);

  if (exists($ficheros{$nombre})) {
    return $ficheros{$nombre}{'src'}
  } else {
    die("El fichero con nombre <$nombre> no existe.")
  }
}

#############################################
# Cache de comandos

sub mostrar_comandos {
  my (%comandos) = (@_);

  say("\nComandos por procesar--------------->");
  foreach my $fichero (keys %comandos) {
    my @add = mostrar_comandos_add($fichero,%comandos); 
    my @del = mostrar_comandos_del($fichero,%comandos); 
    my @sub = mostrar_comandos_sub($fichero,%comandos);

    print("  $fichero: añadir [@add] quitar [@del] sustituir [");
    print(join(", ",map{"[$_->[0],$_->[1]]"} @sub));
    say("]");
  }

  say "";
}

sub mostrar_comandos_add{
  my ($key,%comandos) = (shift,@_);

  return 
      grep { $comandos{$key}{$_} eq "1" } 
      keys %{$comandos{$key}};
}

sub mostrar_comandos_del{
  my ($key,%comandos) = (shift,@_);

  return 
      grep { $comandos{$key}{$_} eq "-1" } 
      keys %{$comandos{$key}};
}

sub mostrar_comandos_sub{
  my ($key,%comandos) = (shift,@_);

  return 
      map { [$_, $comandos{$key}{$_}]}
      grep { 
        my $comando = $comandos{$key}{$_}; 
        $comando ne "1" && $comando ne "-1"} 
      keys %{$comandos{$key}};
}

# se muestra una dependencia lineal de uno en uno
# A, B, C implica A->B->C y B/>A y C/>B
sub dependencia {
  my ($nombres,%comandos) = (shift,@_);
  my @nombres = map {extrae_nombre($_)} @{$nombres};

  my $dependencia = shift @nombres;
  my $bloque_dependencia = extrae_bloque($dependencia);
  while (@nombres) {
    my $posterior = shift @nombres;
    my $bloque_posterior = extrae_bloque($posterior);

    say " $dependencia -> $posterior ";

    # procesado 
    if ($posterior ne $dependencia) {
      $comandos{$posterior}{extrae_bloquenombre($dependencia,$posterior)} = 1;
      $comandos{$dependencia}{extrae_bloquenombre($posterior,$dependencia)} = -1;
    }

    $dependencia = $posterior;
    $bloque_dependencia = $bloque_posterior;
  }

  return %comandos
}

# se elimina cualquier dependencia entre cada par de 
# la lista pasada A, B, C 
# implica A/>B, B/>A, A/>C, C/>A, B/>C y C/>B
sub independencia {
  my ($nombres,%comandos) = (shift,@_);
  my @nombres = map {extrae_nombre($_)} @{$nombres};

  while (@nombres) {
    my $first = shift @nombres;
    foreach my $rest (@nombres) {
      if ($first ne $rest) {
          $comandos{$first}{extrae_bloquenombre($rest,$first)} = -1;
          $comandos{$rest}{extrae_bloquenombre($first,$rest)} = -1;
      }
    }
  }

  return %comandos
}

# Crea comando de sustituir en $nombre la dependencia 
# $antiguo y la sustituye por $nuevo (si $antiguo está).
sub sustituir {
  my ($nombres,%comandos) = (shift,@_);
  my ($nombre,$antiguo,$nuevo) = map {extrae_nombre($_)} @{$nombres};

  $comandos{$nombre}{extrae_bloquenombre($antiguo,$nombre)} = 
    extrae_bloquenombre($nuevo,$nombre);

  return %comandos
}

#############################################
# Comandos
my %ayuda;

$ayuda{"show"} =<<END;
show [ficheros]*
    Muestra las dependencias de los ficheros solicitados.
    Si un fichero no es un experimentos se ignora.

END
sub comando_show {
  my (@ficheros) = @_;
  @ficheros = 
    grep { exists($ficheros{$_})}  
    map{extrae_nombre($_)} @ficheros;
  say("\n----- Show @ficheros\n");


  my @salida = wrapper_tag(\@ficheros,\&lee_tag,'REQUISITO');
  foreach my $file (@salida) {
    say ("$file->[0]: @{$file->[1]}");
  }

}

$ayuda{"renombra"} =<<END;
renombra origen destino
    Renombra fichero y las dependencias.

    Si destino no tiene referencia a directorio se usa el actual
    Si destino no tiene extensión se pone .expm

END
sub comando_renombra {
  my ($origen, $destino) = (shift,shift);

  say("\n----- Renombrar $origen $destino\n");

  # completando el nombre de destino si fuera abreviado
  $destino = "$destino.expm" unless $destino=~m!\.!;
  # ojo, necesita al menos 2 directorios para extraer 
  $destino = "../".extrae_bloque($origen).'/'.$destino if (()=$destino=~m!/!g)==0;
  $destino = "./$destino" if (()=$destino=~m!/!g) ==1;

  # copiamos el fichero
  my $src_origen = extrae_src($origen);
  io($src_origen) > io($destino);
  
  # añadido a la base de datos
  %ficheros = add_fichero($destino,%ficheros);
  my $nombre = extrae_nombre($destino);

  my %comandos;

  # dependencias del fichero ajustando bloques
  my @dependencias = wrapper_tag($origen,\&lee_tag,'REQUISITO');
  @dependencias = @{$dependencias[0][1]};

  %comandos = dependencia([$_,$nombre],%comandos) for @dependencias;
   
  # dependencias de todos los demás elementos
  %comandos = sustituir([$_,$origen,$nombre],%comandos) for keys %ficheros;

  # aplica cambios
  mostrar_comandos(%comandos);
  file_update_tag($_,"REQUISITO",
    [mostrar_comandos_add($_,%comandos)],
    [mostrar_comandos_del($_,%comandos)],
    [mostrar_comandos_sub($_,%comandos)],
    ) for keys %comandos;


  # borrando el fichero de origen
  delete $ficheros{extrae_nombre($origen)};
  io($src_origen)->unlink;

}

$ayuda{"dependencia"} =<<END;
dependencia [<ficheros>]{2,}
    Genera una relación de dependencia
    para que los ficheros aparezcan en dicho orden.
    Si se indican más de 2 elementos se establece una cadena
    de dependencia A->B->C->...

    Solo evita dependencias circulares inmediatas
    Si se escribe A->B, borra B-A

END
sub comando_dependencia {
  my (@nombres) = @_;

  @nombres = verifica_nombres(@nombres);
  return unless @nombres >=2;
  say("\n----- Dependencia @nombres\n");

  my %comandos;
  %comandos = dependencia(\@nombres,%comandos);

  mostrar_comandos(%comandos);
  file_update_tag($_,"REQUISITO",
    [mostrar_comandos_add($_,%comandos)],
    [mostrar_comandos_del($_,%comandos)],
    [mostrar_comandos_sub($_,%comandos)],
    ) for keys %comandos
}


$ayuda{"intercala"} =<<END;
intercala [<ficheros>]{2,}
    Intercala elementos entre otros por orden de dependencia.
    Si existe la dependencia A->C, y se llama intercala A B C
    genera la cadena de dependencia A->B->C y borra A->C.
    Con lo que el efecto es que se intercala un experimento entre
    dos experimentos. 

    El efecto es como el comando dependencia, pero borrando 
    cualquier relación previa entre todos los elementos 
    involucrados.

    Solo evita dependencias circulares inmediatas dentro
    de los elementos indicados, pero no considera el grafo entero

END
sub comando_intercala {
  my (@nombres) = @_;

  @nombres = verifica_nombres(@nombres);
  return unless @nombres >=2;
  say("\n----- Intercala @nombres\n");

  my %comandos;
  %comandos = independencia(\@nombres,%comandos);
  %comandos = dependencia(\@nombres,%comandos);

  mostrar_comandos(%comandos);
  file_update_tag($_,"REQUISITO",
    [mostrar_comandos_add($_,%comandos)],
    [mostrar_comandos_del($_,%comandos)],
    [mostrar_comandos_sub($_,%comandos)],
    ) for keys %comandos
}

$ayuda{"base"} =<<END;
base [<ficheros>]{2,}
    De la lista de ficheros suministrada, toma el primero como base
    (o dependencia, de todos los demás). 

    No afecta a las relaciones de los demás elementos entre si. 

    Solo impide la circularidad entre la base y cada uno de los
    ficheros suministrados

END
sub comando_base {
  my (@nombres) = @_;

  @nombres = verifica_nombres(@nombres);
  return unless @nombres >=2;
  say("\n----- Base @nombres\n");
  my $base = shift(@nombres);

  my %comandos;
  foreach (@nombres) {
    %comandos = dependencia([$base,$_],%comandos);
  }

  mostrar_comandos(%comandos);
  file_update_tag($_,"REQUISITO",
    [mostrar_comandos_add($_,%comandos)],
    [mostrar_comandos_del($_,%comandos)],
    [mostrar_comandos_sub($_,%comandos)],
    ) for keys %comandos
}

$ayuda{"tope"} =<<END;
tope [<ficheros>]{2,}
    De la lista de ficheros suministrada, tomos los ficheros 
    se convierten en dependencia del último. 

    No afecta a las relaciones de los demás elementos entre si. 

    Solo impide la circularidad entre el tope y cada uno de los
    ficheros suministrados

END
sub comando_tope {
  my (@nombres) = @_;

  @nombres = verifica_nombres(@nombres);
  return unless @nombres >=2;
  say("\n----- Tope @nombres\n");
  my $tope = pop(@nombres);

  my %comandos;
  foreach (@nombres) {
    %comandos = dependencia([$_,$tope],%comandos);
  }

  mostrar_comandos(%comandos);
  file_update_tag($_,"REQUISITO",
    [mostrar_comandos_add($_,%comandos)],
    [mostrar_comandos_del($_,%comandos)],
    [mostrar_comandos_sub($_,%comandos)],
    ) for keys %comandos
}


$ayuda{"borradependencia"} =<<END;
borradependencia [<ficheros>]+
    Elimina la lista de dependencias de los ficheros
    pasados como argumento

END
sub comando_borradependencia {
  my (@ficheros) = @_;

  @ficheros = verifica_nombres(@ficheros);
  return unless @ficheros;

  my $tag = "REQUISITO";
  file_wrapper_tag(\@ficheros,\&borra_tag,$tag);
}

$ayuda{'help'} =<<END;
help
    Muestra la ayuda de todos los comandos disponibles.

help [<comando>]+
    Muestra la ayuda de los comandos indicados.

END
sub comando_help {
  my @args = @_;
  my $ayuda_mostrada=0;

  say "";

  if (@args==0) {
    @args = keys %ayuda;
  }

  foreach my $comando (keys %ayuda) {
    if (grep (/$comando/,@args)) {
      say($ayuda{$comando});
      $ayuda_mostrada++;
    }
  }

  if ($ayuda_mostrada==0) {
    print <<END;
Los comandos que ha solicitado no existen. Use "$0 help" para ver todos los
comandos diponibles.

END
  }

}

#############################################
sub verifica_nombres {
  my (@ficheros) = @_;

  # intentamos extraer el src muere si no existe
  return 
    map { extrae_nombre($_)}
    map { extrae_src($_)} 
    @ficheros;
}

## Toma una serie de ficheros le aplica el filtro de funcion
## y le pone a cada uno $contenido.
# TODO DEPRECATED
sub wrapper_tag {
  my($ficheros,$funcion,$tag,$contenido) = (shift,shift,shift,shift);

  $ficheros = forceArray($ficheros);

  my @salida =    
    map { 
      my @salida;
      if ($contenido) {
        @salida = $funcion->($tag,$contenido,@{$_->[1]})
      } else {
        @salida = $funcion->($tag,@{$_->[1]})
      };
      #say Dumper({"nombre"=>$_->[0],"salida"=>\@salida,"tag"=>$tag});
      [$_->[0], \@salida]
    }
    grep { $_->[1]}
    map {
      my @lines = carga_fichero($_);
      [ extrae_nombre($_), \@lines]}
    @$ficheros;

    #say Dumper({"salida"=>\@salida});
  return @salida
}

# TODO DEPRECATED 
sub file_wrapper_tag {
  my($ficheros,$funcion,$tag,$contenido) = (shift,shift,shift,shift);

  my @nombre_result = wrapper_tag($ficheros,$funcion,$tag,$contenido);

  foreach my $nombre_result (@nombre_result) {
    my ($nombre,$resultado) = @$nombre_result;
    my $fichero = extrae_src($nombre);
    io($fichero)->print(@$resultado);
    io($fichero)->close;
  }
}

sub file_update_tag {
  my($nombre,$tag,$add,$del,$sub) = (shift,shift,shift,shift,shift);

  my @lines = carga_fichero($nombre);
  @lines = add_tag_content($tag,$add,@lines) if @$add;
  @lines = del_tag_content($tag,$del,@lines) if @$del;
  @lines = sub_tag_content($tag,$sub,@lines) if @$sub;

  my $fichero = io(extrae_src($nombre));
  $fichero->print(@lines);
  $fichero->close;
}

sub carga_fichero {
  my ($fichero) = (shift);

  # se le añade la extensión si no viene
  $fichero = extrae_src($fichero);

  # verificación para ver si existe.
  if (!io($fichero)->exists()) {
    say("Fichero: <$fichero> no existe. Saltándolo");
    return undef;
  }

  say("Fichero <$fichero>: ");
  # copia de seguridad
  io($fichero) > io("$fichero.bak");

  # cargamos el fichero en memoria
  my @lines = io($fichero)->slurp;

  return @lines;
}

## lee el tag y le añade el contenido pasado (si no está duplicado)
sub add_tag_content {
  my ($tag,$newtokens,@lines) = (shift,shift,@_);

  # force $newtokens to be a ref ARRAY
  $newtokens = forceArray($newtokens);
  say("  Añadiendo: [@{$newtokens}] a <$tag>");

  # lee tokens originales
  my %tokens = map { $_ => 1} lee_tag($tag,@lines);

  # añade los tokens
  foreach my $newtoken (@$newtokens) {
    $tokens{$newtoken} = 1;
  }

  my @tokens = keys %tokens;
  @lines = escribe_tag($tag,\@tokens,@lines);

  return @lines
}

## lee el tag y le quita el contenido pasado (si existe)
sub del_tag_content {
  my ($tag,$newtokens,@lines) = (shift,shift,@_);

  # force $newtokens to be a ref ARRAY
  $newtokens = forceArray($newtokens);
  say("  Eliminando: [@{$newtokens}] en <$tag>");

  my %tokens = map { $_ => 1} lee_tag($tag,@lines);
  foreach my $newtoken (@$newtokens) {
    delete $tokens{$newtoken} if exists($tokens{$newtoken})
  } 

  my @tokens = keys %tokens;
  @lines = escribe_tag($tag,\@tokens,@lines);

  return @lines
}

## lee el tag y le sustituye el contenido pasado (si existe)
sub sub_tag_content {
  my ($tag,$oldnewtokens,@lines) = (shift,shift,@_);

  my %tokens = map { $_ => 1} lee_tag($tag,@lines);
  my $cambio = 1==0;

  foreach my $pair (@$oldnewtokens) {
    my ($old,$new) = @$pair;
    if (exists($tokens{$old})) {
      say("  Sustituyendo $old por $new en <$tag>");
      delete $tokens{$old};
      $tokens{$new}=1;
      $cambio = 1==1;
    }

  }

  if ($cambio) {
    my @tokens = keys %tokens;
    @lines = escribe_tag($tag,\@tokens,@lines);
  }

  return @lines
}

## escribe el tag con el contenido, sustituyendo lo que hubiera antes
sub escribe_tag { 
  my ($tag,$tokens,@lines) = (shift,shift,@_); 
  # force $tokens to be a ref ARRAY 
  $tokens = forceArray($tokens);

  # eliminamos posibles tags anteriores
  @lines = borra_tag($tag,@lines);

  # localizamos el punto de inserción del tag
  my $punto_insercion = 0;
  for ($punto_insercion = 0; $punto_insercion < @lines; ++$punto_insercion) {
    last unless $lines[$punto_insercion] =~ /^\s*[A-Z]+:/;
  }

  # inserción
  splice(@lines,$punto_insercion,0,"$tag: ".join(", ",@$tokens)."\n");

  # escribimos el fichero
  return @lines;

}

## elimina el tag del listado
sub borra_tag {
  my ($tag,@lineas) = (shift,@_);

  @lineas = grep { !(/^\s*$tag:/) } @lineas;

  return @lineas;
}

## lee campos en una línea con cabecera
sub lee_tag {
  my ($tag,@lines) = (shift,@_);

  my %campos;
  my $pat = qr/^$tag:\s*(.*)$/m;
  foreach my $texto (@lines) {
    while ($texto =~ /$pat/g) {
      my @campos_en_linea = 
        grep {/\S/}
        map { s/^\s+|\s+$//g; $_ } 
        split(/,/,$1);

      # para evitar duplicar campos
      foreach my $campo (@campos_en_linea) {
        $campos{$campo} = 1;
      }
    }
  }

  return keys %campos
}

## toma una referencia y la convierte en ref a ARRAY
sub forceArray {
  my ($ref)=(shift);

  # force $tokens to be a ref ARRAY
  if (ref $ref ne 'ARRAY') {
    $ref = [$ref];
  }

  return $ref
}

# ############################################
# MAIN
my $comando = shift @ARGV;

if (!defined $comando) {
  say "No se introdujo ningún comando.";
  say "$0 help para ver los comandos disponibles";
  exit;
}

# Ejecución del comando
if (defined $comandos{$comando}) {
  $comandos{$comando}->(@ARGV);
}

