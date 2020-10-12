function [outLeft, outRight] = limit_ild(inLeft, inRight)
% LIMIT_ILD Limits RMS level difference to maximum ILD (assumed to be 20 dB).
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

  % Constants
  MAX_ILD = 20; % dB
  MAX_RMS_RATIO = 10 ^ (MAX_ILD / 20); % dB to factor/ratio

  leftRMS = rms(inLeft);
  rightRMS = rms(inRight);
  rmsRatio = leftRMS / rightRMS;
  rmsdB = 20 * log10(rmsRatio);

  outLeft = inLeft;
  outRight = inRight;

  if rmsdB > MAX_ILD % left signal is too loud
    outLeft = outLeft .* MAX_RMS_RATIO ./ rmsRatio;
  elseif rmsdB < -MAX_ILD % right signal is too loud
    outRight = outRight .* MAX_RMS_RATIO .* rmsRatio;
  end
end
