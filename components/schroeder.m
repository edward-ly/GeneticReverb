function out = schroeder(in, mode)
% SCHROEDER Calculates the energy decay (Schroeder) curve of impulse response.
%
% Input arguments:
% in = vector containing impulse response energy
% mode = if set to 'dB', convert values to decibel units (optional)
%
% Output arguments:
% out = vector containing energy decay curve
%
    % Require all arguments
    if nargin < 1, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    out = in .* in;
    for i = (length(in) - 1):-1:1
        out(i) = out(i) + out(i + 1);
    end

    if nargin > 1 && strcmp(mode, 'dB'), out = 10 .* log10(out); end
end

