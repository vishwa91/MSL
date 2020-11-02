%% Script to simulate Micro-baseline Structured Light (MSL) performance
%
% Citation:
% Vishwanath Saragadam, and Jian Wang, and Mohit Gupta, and Shree Nayar,
% "Micro-baseline Structured Light", IEEE Intl. Conf. Computer Vision, 2019
% 

% Simple vectorizing function
vec = @(x) x(:);

% Normalization of values from 0 - 1
normalize = @(x) (x - min(x(:)))/(max(x(:)) - min(x(:)));

%% Simulation constants
min_depth = 100;                    % Minimum depth in mm
max_depth = 2000;                   % Maximum depth in mm
pattype = 'triangle';    			% Pattern type
f = 25;                             % Focal length (~mobile config)
baseline = 20; 						% Baseline in mm
period = 20; 						% Pattern period in pixels

%% Load data -- Please place Middlebury texture and depth image in this folder
albedo_rgb = imread('albedo.png');
albedo = double(rgb2gray(albedo_rgb))/255;

% To simulate error due to albedo and guide mismatch, set albedo to red channel
% and guide to green channel
albedo = double(albedo_rgb(:, :, 1))/255;
guide = double(albedo_rgb(:, :, 2))/255;

albedo_rgb = double(albedo_rgb);

disparity = imread('disparity.png');
disparity_base = normalize(double(disparity));

[H, W] = size(disparity);
[X, Y] = meshgrid(1:W, 1:H);

%% Fix zero values in disparity -- these interfere with simulations
[Xn, Yn] = find(disparity_base ~= 0);
[Xz, Yz] = find(disparity_base == 0);

zero_vals = griddata(Xn, Yn, disparity_base(disparity_base ~= 0), ...
                          Xz, Yz);
disparity_base(disparity_base == 0) = zero_vals;

%% Compute disparity range
max_disparity = f*baseline/min_depth;
min_disparity = f*baseline/max_depth;

% Window size can be 1 period, but use 2 periods for robustness
winsize = [period, period];

% Create pattern
[pat, ~] = get_pattern([H, W], period, pattype); dx = 0;

% Compute pattern derivative
for didx = 1:4
	dx = dx + (pat - circshift(pat, [0, didx]))/didx;
end
dx = dx/4;

%% The tip of triangle is not differentiable, so we need to give it
%  zero weight. Please check supplementary for more details.
if strcmp(pattype, 'triangle')
	wt = double(abs(pat - 0.5) < 0.25);
else
	wt = ones(H, W);
end

% Now create disparity map
disparity = (max_disparity - min_disparity)*disparity_base + min_disparity;

% Compute depth
depth = baseline*f./disparity;

% Generate pattern image
pat_disp = interp2(X, Y, pat, X-disparity, Y).*albedo;

%% Now compute disparity with MSL algorithm
d = msl(pat_disp.*wt, pat.*wt, -dx.*wt, winsize, guide);

% Remove erroneous entries
valid = ~(isnan(d) + isinf(d) + (d > max_disparity) + (d < min_disparity));
valid(1:10, :) = false; valid(end-10:end, :) = false;
valid(:, 1:10) = false; valid(:, end-10:end) = false;

d(isinf(d)) = disparity(isinf(d));
d(isnan(d)) = disparity(isnan(d));
d = conv2(d, ones(winsize)/prod(winsize), 'same');

d(d > max_disparity) = max_disparity; 
d(d < min_disparity) = min_disparity; 

%% Estimate depth
depth_hat = baseline*f./d;
depth_hat(depth_hat > max(depth(:))) = max(depth(:));
depth_hat(depth_hat < min(depth(:))) = max(depth(:));

% Compute error
err = mean(vec(abs(depth(valid) - depth_hat(valid))));

fprintf('Mean depth error: %.2fmm\n', err);

subplot(2, 2, 1); imshow(albedo, []); title('Scene'); 
subplot(2, 2, 2);imshow(pat_disp, []); title('Captured image');
subplot(2, 2, 3); imshow(max(depth(:)) - depth, [], 'Colormap', jet(256)); title('Ground truth depth');
subplot(2, 2, 4); imshow(max(depth(:)) - depth_hat, [], 'Colormap', jet(256)); title('MSL depth');
