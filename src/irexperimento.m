%% usage: irexperimento(NUM)
%% usage: irexperimento NUM
%%
%% Va al experimento indicado por NUM 
%%
%% Para ver el número asociado a cada experimento
%% se puede usar el comando "indice"
%
% Projecto kudos de octave 
% (C) 2013 Javier M. Mora-Merchan et al.
% BSD 3-Clause License



function irexperimento(nuevonumexp)
  global numexp;
  numexp=str2double(nuevonumexp);
  
  experimento(0);
end
