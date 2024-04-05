%% Utilidad muestra la cabecera
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = cabecera(borde,text,offset)
  % valor por defecto al offset
  if (nargin<3)
    offset = 0;
  end

  % otra constante
  newline=char(10);

  ban = bandera(1,borde,text);
  linea = repmat([borde],1,length(ban)+offset);
  out = [linea,newline,ban,newline,linea,newline];
end

