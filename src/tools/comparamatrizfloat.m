% Compara matrices de floats
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = comparamatrizfloat(a,b,tol)  
  out = all(size(a)==size(b)) && all((comparafloat(a,b,tol))(:));
end


