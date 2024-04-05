%  Pinta un recuadro con texto
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = bandera(num,borde,text)
  ban = repmat([borde],1,num);
  out = [ban ' ' text ' ' ban];
end

