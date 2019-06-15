function out = normalize_signal(in, peak, mode)
% NORMALIZE_SIGNAL Normalizes a signal so that all values are no higher than
% peak level.
% out = output signal
% in = input signal
% peak = max value
% mode = ['each', 'all'] normalize each channel independently or normalize
% entire signal at once
    if mode == "each"
        [rows, cols] = size(in);
        out = zeros(rows, cols);

        for a = 1:cols
            out(:, a) = peak .* in(:, a) ./ max(abs(in(:, a)));
        end
        return
    end

    if mode == "all"
        out = peak .* in ./ max(max(abs(in)));
        return
    end

    error("Unknown mode '%s' (must be 'each' or 'all').", mode);
end
