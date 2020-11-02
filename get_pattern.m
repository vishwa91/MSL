function [pat, dx] = get_pattern(patsize, period, pattype)
	% Function to get pattern of choice
	%
	% Inputs:
	% 	patsize: Size of pattern as a two-tuple
	% 	period: Period of the pattern
	% 	pattype: Type of pattern:
	% 		'triangle': Symmetric triangle
	% 		'sinusoid': Sinusoid
	% 		'ramp': Ramp
	%
	% Outputs:
	% 	pat: Pattern
	% 	dx: Analytical derivative of pattern

	% Create a single period
	if strcmp(pattype, 'triangle')
		if mod(period, 2) == 0
			pat1 = linspace(0, 1, period/2+1);
			pat2 = linspace(1, 0, period/2-1);
			pat = [pat1, pat2];
		else
			pat1 = linspace(0, 1, (period+1)/2);
			pat2 = linspace(1, 0, (period-1)/2);
			pat = [pat1, pat2];
		end
		%dx = 2*ones(1, period/2)/period;
		%dx = [dx, -dx];
		dx = gradient(pat);
	elseif strcmp(pattype, 'sinusoid')
		pat = 0.5 + 0.5*cos(2*pi*linspace(0, 1, period));
		dx = -0.5*2*pi*cos(2*pi*linspace(0, 1, period))/period;
	elseif strcmp(pattype, 'ramp')
		pat = linspace(0, 1, period);
		dx = ones(1, period)/period;
		dx(end) = -1;
	end

	% Create a full row
	pat = repmat(pat, [1, ceil(patsize(2)/period)]);
	dx = repmat(dx, [1, ceil(patsize(2)/period)]);

	% Create the image
	pat = ones(patsize(1), 1)*pat(1:patsize(2));
	dx = ones(patsize(1), 1)*dx(1:patsize(2));

end
