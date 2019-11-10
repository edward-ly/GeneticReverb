function [out, outdB] = schroeder(in)
% SCHROEDER Calculates the energy decay (Schroeder) curve of impulse response.
%
% Input arguments:
% in = vector containing impulse response energy
%
% Output arguments:
% out = vector containing energy decay curve
% outdB = vector containing energy decay curve in decibels
%
    % Require input argument and one output argument
    if nargin < 1, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    out = in .* in;
    for i = (length(in) - 1):-1:1
        out(i) = out(i) + out(i + 1);
    end

    if nargout > 1, outdB = 10 .* log10(out); end
end
