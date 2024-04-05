% Compara número complejo
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = comparacomplex(a,b,tol)
  out = (abs(a-b) < tol);
end
