% Verifica si la respuesta es correcta
%
% Projecto kudos de octave 
% (C) 2023 Javier M. Mora-Merchan et al.
% BSD 3-Clause License

function out = verificarTrue(texto,in)
      if (in)
	disp(['Verificando ',texto,': ',banderaOK]);
	out = 1;
      else
	disp(['Verificando ',texto,': ',banderaFAIL]);
	out = 0;
      end
end
