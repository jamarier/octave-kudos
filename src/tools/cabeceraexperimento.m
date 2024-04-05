%% Utilidad muestra la cabecera de un experimento
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License


function out = cabeceraexperimento(titulo,offset)
  % valor por defecto al offset
  if (nargin<2)
    offset = 0;
  end

  global numexp;
  out = cabecera('=',['Experimento número ', int2str(numexp), ' - ', titulo],-1+offset);
end

