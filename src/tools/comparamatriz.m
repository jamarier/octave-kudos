% Compara matrices de enteros
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = comparamatriz(a,b)
    out = all(size(a)==size(b)) && all((a==b)(:));
end


