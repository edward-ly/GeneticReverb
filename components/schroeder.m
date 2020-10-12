function [out, outdB] = schroeder(in)
% SCHROEDER Calculates the energy decay (Schroeder) curve of impulse response.
%
% Input arguments:
% in = column vector(s) containing impulse responses
%
% Output arguments:
% out = column vector(s) containing energy decay curve(s) of each IR
% outdB = column vector(s) containing energy decay curve(s) in decibels
%
  % Require input argument and one output argument
  if nargin < 1, error('Not enough input arguments.'); end
  if nargout < 1, error('Not enough output arguments.'); end

  % =========================================================================

  out = cumsum(in .^ 2, 'reverse');

  if nargout > 1
    outdB = 10 .* log10(out);
    outdB = bsxfun(@minus, outdB, outdB(1, :)); % Normalize to 0 dB maximum
  end
end
