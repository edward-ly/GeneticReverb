function [outLeft, outRight] = set_ild(inLeft, inRight, ilddB)
% SET_ILD Sets RMS level difference to specified ILD.
% Normalizes the 2nd signal according to overall RMS (entire length of IRs).
%
% Input arguments:
% inLeft = column vector containing first input signal
% inRight = column vector containing second input signal
% ilddB = desired ILD value (dB)
%
% Output arguments:
% outLeft = column vector containing first signal normalized
% outRight = column vector containing second signal normalized
%
  % Require output arguments
  if nargout < 2, error('Not enough output arguments.'); end

  % Require input arguments
  if nargin < 3, error('Not enough input arguments.'); end

  % =========================================================================

  ildRatio = 10 ^ (ilddB / 20); % dB to factor/ratio
  rmsRatio = rms(inLeft) / rms(inRight);

  outLeft = inLeft;
  outRight = inRight .* rmsRatio .* ildRatio;
end
