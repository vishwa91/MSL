function disparity = msl(im, pat, dx, winsize, guide)
	% Function to compute disparity from captured image using micro-baseline
	% structured light equation using fast convolutional method.
	%
	% Inputs:
	% 	im: Captured image
	% 	pat: Pattern that was used for capturing image
	% 	dx: Derivative of pattern along x-axis
	% 	winsize: 2-tuple Size of window for solving MSL equation
	% 	avg: If True, disparity/albedo is averaged over the image
    %   guide: Image that acts as a proxy for albedo. We assume that the 
    %       albedo is a linear scaling of guide.
	%
	% Outputs:
	% 	disparity: Estimated disparity
    
    % Modify pattern and derivative to look like albedo scaled versions
    pat = pat.*guide;
    dx = dx.*guide;
    
	% Create convolution kernel
	kx = ones(winsize(1), 1, 'single')/winsize(1);
    ky = ones(1, winsize(2), 'single')/winsize(2);

	% Create MSL equation images. We essentially solve the following
    % linear inverse problem at each pixel:
    %   | v11 v12 | | albedo           | = | v1c |
    %   | v12 v22 | | albedo*disparity |   | v2c |
    
	v11_img = conv2(conv2(pat.*pat, kx, 'same'), ky, 'same');
	v12_img = conv2(conv2(pat.*dx, kx, 'same'), ky, 'same');
	v22_img = conv2(conv2(dx.*dx, kx, 'same'), ky, 'same');
    
	v1c_img = conv2(conv2(pat.*im, kx, 'same'), ky, 'same');
	v2c_img = conv2(conv2(dx.*im, kx, 'same'), ky, 'same');
    
	% Solve for all pixels simultaneously
    disparity = (-v12_img.*v1c_img + v11_img.*v2c_img)./(v22_img.*v1c_img - v12_img.*v2c_img);
end
