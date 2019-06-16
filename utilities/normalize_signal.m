function out = normalize_signal(in, peak, mode)
% NORMALIZE_SIGNAL Normalizes a signal so that all values are no higher than
% peak level.
% out = output signal
% in = input signal
% peak = max value
% mode = ['all' (default), 'each'] normalize entire signal at once or
% normalize each channel independently
    if nargin < 3 || isempty(mode)
       mode = "all";
    end
    
    [numSamples, numChannels] = size(in);
    if numChannels == 1 || mode == "all"
        out = peak .* in ./ max(max(abs(in)));
        return
    end
    
    if mode == "each"
        out = zeros(numSamples, numChannels);

        for i = 1:numChannels
            out(:, i) = peak .* in(:, i) ./ max(abs(in(:, i)));
        end
        return
    end

    error("Unknown mode '%s' (must be 'each' or 'all').", mode);
end
