function [outLeft, outRight] = normalize_rms(inLeft, inRight)
% NORMALIZE_RMS Normalizes 2nd signal so that RMS level is equal to that of 1st
% signal.
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
    outLeft = inLeft;
    outRight = inRight .* (1 + (leftRMS / rightRMS)) ./ (1 + (rightRMS / leftRMS));
end
