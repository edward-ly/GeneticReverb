function [outLeft, outRight] = normalize_rms(inLeft, inRight)
% NORMALIZE_RMS Normalizes two signals so that RMS levels are equal.
%
% Input arguments:
% inLeft = column vector containing first input signal
% inRight = column vector containing second input signal
%
% Output arguments:
% outLeft = column vector containing first signal normalized
% outRight = column vector containing second signal normalized
%
    % Require output arguments
    if nargout < 2, error('Not enough output arguments.'); end
    
    % Require input arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % =========================================================================

    leftRMS = rms(inLeft);
    rightRMS = rms(inRight);
    outLeft = inLeft .* (1 + (rightRMS / leftRMS));
    outRight = inRight .* (1 + (leftRMS / rightRMS));
end
