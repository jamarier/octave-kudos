% Compara floats
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = comparafloat(a,b,tol)
  out = (abs(a-b) < tol);
end

