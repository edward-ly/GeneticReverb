function ir = init_ir(length)
% INIT_IR Generate a default impulse response with specified length
% This IR contains 1 as the 1st sample and 0 for all other samples (effectively
% passing the audio stream through without any reverb, but with some delay due
% to the convolution).
%
% Input arguments:
% length = length of impulse response
%
% Output arguments:
% ir = row vector containing impulse response
%
    % Require length argument
    if nargin < 1, error('Not enough input arguments.'); end

    if length < 1, ir = []; return; end
    ir = zeros(1, length);
    ir(1) = 1;
end

