Trabajo voluntario 

Última modificación:

# Introducción

Entre el material disponible en la asignatura de Procesamiento de
Señales Multimedia, existe un tutorial básico de conceptos de octave (de
uso muy similar a matlab), técnicas básicas de programación para dicho
software y aplicaciones relativas a la asignatura

En el marco de este tutorial, se ofrece la posibilidad de efectuar un
trabajo voluntario elaborando material para el tutorial con el fín de
completar los contenidos y hacer de este un material complementario para
el estudio de la asignatura.

El tutorial está dividido en actividades o experimentos en el cual se
expone un contenido didactico, se proponen actividades de refuerzo y
verificación del conocimiento adquirido y se verifican que las
respuestas dadas son correctas.

# Condiciones

-   A cada alumno que desee realizar el trabajo se le asignará un número
    de actividades a desarrollar. Dicho número dependerá de la
    dificultad estimada de las mismas.
-   El alumno que entregue las actividades con los contenidos pactados
    será recompensado con 0.5 puntos en la nota final de la asignatura.
    En el caso de no entrega de alguna tarea asignada, mal
    funcionamiento de las mismas o falta de los contenidos pactados, el
    alumno no recibirá ninguna puntuación extra.
-   Los trabajos (exclusivamente los ficheros exp\_\*.expm) se enviarán
    por correo electrónico al profesor Javier M. Mora (jmmora@us.es).
-   La fecha tope de envío de los trabajos será el día del examen final
    de la asignatura.
-   El trabajo de los alumnos será licenciado como BSD 3-Clause Licence
    para permitir el libre acceso y mantenimiento de los experimentos
    entregados.

# Requisitos de software

Aunque las herramientas de generación de los ficheros del tutorial son
multiplataforma (son utilidades existentes libremente en Windows, MacOs
y Linux), los scripts de generación están adaptados especialmente para
el desarrollo desde Linux. Éste es el sistema operativo recomendado para
trabajar en la generación del tutorial. El empleo de otros sistemas
operativos puede requerir adaptación de los ficheros suministrados e
instalación de otras librerías no contempladas (como cygwin en
plataformas windows). No se dará soporte de instalación sobre el
software requerido.

Los requerimientos de software son:

-   un editor de texto sin formato.
-   Perl (con los paquetes Modern::Perl, IO::All y
    [Data::Dumper](data::Dumper)).
-   GNU Make
-   utilidad de compresión "zip" (en el caso de querer obtener todo el
    tutorial compilado en un único fichero).
-   Octave

# Descripción del proyecto

El proyecto de generación del tutorial está compuesto de los siguientes
ficheros y directorios:

-   Makefile: Se encarga de automatizar la generación del tutorial

-   bin: Directorio donde están los scripts en perl que se encargan de
    la conversión de los experimentos en código de octave válido

-   build: Directorio donde se genera el tutorial con todos los ficheros
    necesarios para su ejecución. Dentro de este directorio está

-   Un fichero por cada actividad del tutorial (con el nombre
    > "exp\_\<nombre\>.m")

-   Scripts de operación del tutorial como "anterior.m", "siguiente.m",
    > "repite.m"

-   Fichero de índice: "indice.m". Además de servir dentro de octave, si
    > se lee el contenido, con un editor de textos por ejemplo, se
    > relacionan los distintos experimentos, el orden en el que se ha
    > construido el tutorial y el fichero asociado al mismo.

-   Experimentos: Directorio donde están la descripción individual de
    cada experimento o actividad del tutorial. Se emplea un lenguaje de
    proposito específico para describir el contenido de los ficheros.
    Dicho lenguaje se describe en el apartado siguiente.

-   Src: Directorio donde están los scripts de octave no autogenerados.

-   octavekudos-\<numero\>.zip: fichero comprimido con todos los scripts
    necesarios para ejecutar el tutorial desde octave.

-   trabajo.\*: el texto de este documento en distintos formatos.

-   TODO.org: Lista de tareas por hacer.

## Construcción del tutorial

Desde la carpeta principal del proyecto, ejecutar el comando "make". Los
pasos por las que pasa el sistema de construcción de archivos son:

-   Conversión de los fichero "exp\_\<nombre\>.expm" (lenguaje propio)
    en "exp\_\<nombre\>.m" (script octave). Una reciente modificación
    del lenguaje Perl, ha declarado la construcción given/when como
    experimental. Esto hace que en este paso de disparen, en versiones
    de Perl modernas, avisos de uso de la construcción. Estos avisos
    pueden ser ignorados.

-   Ordenación de las actividades según las dependencias establecidas.
    En el fichero Makefile se indican (variable BLOQUES) que
    subdirectorios de experimentos se van a emplear en el tutorial que
    se está construyendo. Cada bloque se ordena de forma independiente.

    Los experimentos pueden incluir detrás de qué otros experimentos han
    de ir (debido a que se requiera conocimientos explicados en otras
    actividades). El experimento que no incluya antecendentes será el
    primero que se ejecute dentro de ese bloque. Si se produce el aviso:
    "SIN PADRE: \<nombre experimento1\> \<nombre experimento2\> \..."
    indica que ninguno de los experimentos indicados tienen
    antecedentes. El programa escoge uno como raiz y continúa. Para
    evitar el aviso, es necesario añadir algún antecedente a todos los
    experimentos indicados en la lista salvo a uno (que queda como
    raiz).

    El error: "No hay ningún elemento raiz" detiene el programa ya que
    indica que todos los experimentos dependen de otros y por lo tanto
    existe circularidad en las dependencias. Hasta que no se resuelva,
    el programa se detendrá en este punto.

    En caso de que el programa encuentre una circularidad entre las
    dependencias, esto es: que experimento sea antecedente de un
    antecendente suyo, el programa se detendrá dando el mensaje de
    error: "Circularidad no resuelta" y un listado de los experimentos
    restantes y sus prelaciones. Al igual que el, ya mencionado, error
    de "No hay ningún elemento raiz", es necesario corregir los
    antecedentes de los experimentos para que el programa continue el
    procesado.

    Todo precedente indicado cuyo fichero no exista será ignorado y se
    mostrará un mensaje de aviso: "NO EXISTE: \<experimento
    antecedente\> requerido por \<experimento en proceso\>". Dicha
    dependencia se ignorará en la ordenación. Para eliminar dicho aviso
    hay que corregir la lista de dependencias del fichero \<experimento
    en proceso\>".

-   Movido de los ficheros generados al directorio build.

Si se deseara un fichero comprimido, la instrucción "make zip" generará
el fichero con la fecha de creación del tutorial.

# Descripción de los experimento. 

La descripción de un experimento se realizará en un fichero de texto sin
formato. El nombre del fichero ha de tener el siguiente formato
"exp\_\<nombre\>.expm" donde \<nombre\> sea descriptivo de la actividad
SIN ESPACIOS.

Con el fín de hacer la sintaxis de descripción del experimento muy
simple, cada línea del fichero tiene una única función. Dicha función es
definida por la primera palabra (o secuencia de caracteres) que aparezca
en dicha línea y continúa hasta el final de esta. Dicha palabra la
llamaremo "comando". En general, los espacios antes y después de los
comandos son ignorados.

Los comandos son (OJO: el empleo de mayúsculas es relevante además es
obligatorio usar los dos puntos si aparece en el comando):

-   "NOMBRE:" Indican el nombre del experimento

-   "#" Comentario toda la línea es ignorada.

-   "AUTOR:" El autor de la actividad. Si no usa, se entiende que se
    renuncia a la autoría cediendosela al autor del sistema de
    generación del tutorial.

-   "OBJETIVO:" Objetivo de la actividad actual. En caso de no tener
    objetivo, se usa el nombre del experimento.

-   "REQUISITO:" el nombre de un experimento antecedente. En el caso de
    varios requisitos, son necesarios una línea por cada requisito
    necesario.

-   "EJEMPLO-IN:" Texto de ejemplo que se muestra en el tutorial como
    texto que se puede introducir en la consola de octave

-   "EJEMPLO-OUT:" Procesa el comando de octave que le sigue y muestra
    la solución. Este comando es muy fragil y solo muestra resultados
    que sean un número.

-   "EJEMPLO-OUT\*:" Para los casos que "EJEMPLO-OUT:" no funciona, en
    este caso muestra el resto de la línea como si fuera una salida de
    octave. Si son necesarias varias líneas, es necesario poner
    "EJEMPLO-OUT\*:" al inicio de cada una.

-   "TAREA" Muestra en el texto del tutorial la separación entre
    Enseñanza y Ejercicio.

-   "VARIABLE: \<nombre\> , \<valor\>" Declara una variable que será
    usada para pasar valores entre la consola y el script de
    comprobación de la tarea y le asigna un valor inicial. Por
    limitaciones en el sistema, una actividad solo puede contener hasta
    6 variables de comunicación cuyos nombres han de escogerse entre:
    "A", "B", "C", "s", "r" y "t".

-   "PREVERIFICACION:" Código de octave que se introduce literalmente en
    el script del experimento antes de efectuar la verificación de la
    tarea solicitada. En el caso de necesitar varias líneas, es
    necesario introducir el comando al inicio de cada línea. Entre otras
    cosas puede servir para calcular la solución pedida o para definir
    una función de comparación específica.

-   "VERIFICACION: \<nombre\>, CONDICION \<test\>" nombre es el texto
    que aparecerá mientras se verifica la condición. \<test\> es código
    en octave que debe devolver 1 en caso de que la verificación sea
    correcta y 0 en caso contrario.

    Existen una serie de funciones pre diseñadas de test de distintos
    tipos de valores (en el fichero src/experimento.m)

-   comparafloat(a,b,tol) si a y b están más cercanos que tol.

-   comparacomplex(a,b,tol) compara si el módulo de a y b es inferior a
    > tol

-   comparastring(a,b) si las dos variables de texto son iguales

-   comparamatriz(a,b) sin las dos matrices son iguales (números
    > enteros)

-   comparamatrizfloat(a,b,tol) si la diferencia de cada elemento de a
    > con el elemento en la misma posición de b es menor que tol.

    De ser necesario otro tipos de comparaciones, se puede crear una
    función local de comparación empleando el comando "PREVERIFICACION:"
    para crear dicha función.

    Por cada verificación que se efectúe en la actividad, es necesario
    una nueva linea con el comando "VERIFICACION:"

-   "SINVERIFICACION". En aquellos casos en los que no exista una
    verificación, se ha de usar este comando.

Cualquier otra linea de texto que no tenga ninguno de estos comandos, se
considerará texto de explicación y aparecerá tal cual al ejecutar el
script del experimento. Para mantener la consistencia en los textos,
estas líneas han de tener 70 o menos caracteres por línea.

Si una palabra del texto de explicación empieza con "f:" esta se
representará en el tutorial entre comillas.

## Ejemplos de experimentos

exp_asignacion.expm

+----------------------------------------------------------------------+
| NOMBRE: Asignación                                                   |
|                                                                      |
| AUTOR: Javier M Mora                                                 |
|                                                                      |
| OBJETIVO: Asignación de variables                                    |
|                                                                      |
| REQUISITO: exp_ayuda                                                 |
|                                                                      |
| Los resultados temporales o finales que se obtengan pueden asociarse |
| a                                                                    |
|                                                                      |
| variables (a su nombre) para su posterior uso.                       |
|                                                                      |
| Para realizar la asignación se pone el nombre de la variable         |
| deseada,                                                             |
|                                                                      |
| el signo igual y el valor que se le desee asignar.                   |
|                                                                      |
| EJEMPLO-IN: A=2                                                      |
|                                                                      |
| Esta instrucción asignará el valor f:2 a la variable f:A.            |
|                                                                      |
| TAREA                                                                |
|                                                                      |
| * Asigne a la variable f:A el valor f:2 tal y como se muestra en el |
| ejemplo                                                              |
|                                                                      |
| VARIABLE: A, 0                                                       |
|                                                                      |
| VERIFICACION: A==2 CONDICION A==2                                    |
|                                                                      |
| * Asigne a la variable f:s el valor f:3.                            |
|                                                                      |
| VARIABLE: s, 0                                                       |
|                                                                      |
| VERIFICACION: s==3 CONDICION s==3                                    |
+----------------------------------------------------------------------+

exp_cadenas.expm

+----------------------------------------------------------------------+
| NOMBRE: La naturaleza de las cadenas                                 |
|                                                                      |
| OBJETIVO: Entender que una cadena no es más que un vector visto de   |
| otra forma                                                           |
|                                                                      |
| REQUISITO: exp_ayuda                                                 |
|                                                                      |
| REQUISITO: exp_repeticionvectores                                    |
|                                                                      |
| Una cadena no es más que un array de números enteros en el que cada  |
|                                                                      |
| número representa el código ascii de cada caracter. Por lo tanto se  |
| le                                                                   |
|                                                                      |
| aplican las mismas reglas de composición de los vectores.            |
|                                                                      |
| Concatenación de cadenas:                                            |
|                                                                      |
| EJEMPLO-IN: A='hola', B = [A ' y adios' ]                      |
|                                                                      |
| Igualmente, se pueden aplicar distintos operadores                   |
|                                                                      |
| EJEMPLO-IN: A='hola', A+1                                          |
|                                                                      |
| aunque en ese caso se pierde el caracter de cadena y el resultado se |
|                                                                      |
| muestra numéricamente.                                               |
|                                                                      |
| TAREA                                                                |
|                                                                      |
| VARIABLE: A=\'\'                                                     |
|                                                                      |
| \* Asigne a A la palabra \"hola\"                                    |
|                                                                      |
| VERIFICAR: Cadena \"hola\" CONDICION comparastring(A,\'hola\')       |
|                                                                      |
| VARIABLE: B=\'\'                                                     |
|                                                                      |
| \* Asigne a B una cadena con la palabra \"hola\" repetida 100 veces  |
| (sin                                                                 |
|                                                                      |
| espacios)                                                            |
|                                                                      |
| VERIFICAR: Cadena \'hola\'x100 CONDICION                             |
| comparastring(B,repmat(A,1,100))                                     |
+----------------------------------------------------------------------+
