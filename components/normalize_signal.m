function out = normalize_signal(in, peak, mode)
% NORMALIZE_SIGNAL Normalizes a signal so that all values are no higher than
% peak level.
%
% Input arguments:
% in = column vector(s) containing input signal(s)
% peak = max value
% mode = ['all' (default), 'each'] normalize entire signal at once or
% normalize each channel independently
%
% Output arguments:
% out = column vector(s) containing output signal(s)
%
    % Require output argument
    if nargout < 1, error('Not enough output arguments.'); end
    
    % Require in and peak arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % Set missing arguments
    if nargin < 3, mode = 'all'; end

    % =========================================================================

    [numSamples, numChannels] = size(in);
    if numChannels == 1 || strcmp(mode, 'all')
        out = peak .* in ./ max(abs(in), [], 'all');
        return
    end
    
    if strcmp(mode, 'each')
        out = zeros(numSamples, numChannels);

        for i = 1:numChannels
            out(:, i) = peak .* in(:, i) ./ max(abs(in(:, i)));
        end
        return
    end

    error('Unknown mode "%s" (must be "each" or "all").', mode);
end
