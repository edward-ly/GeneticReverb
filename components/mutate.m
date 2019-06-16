function out = mutate(in, MUTATION_RATE, SAMPLE_RATE)
% MUTATE Changes the population's values with some probability.
% out = output population
% in = input population
% Current algorithm: for each affected sample, multiply its value by a random
% factor from the standard normal distribution.
% Also affect neighboring samples (1ms width) by smoothing and normalizing
% mutation curve (to preserve shape).
    out = in;
    [I, J] = size(out);
    mutValues = double(rand(I, J) < MUTATION_RATE) .* randn(I, J);
    mutValuesPeak = max(max(abs(mutValues)));
    for j = 1:J
        mutValues(1, j) = smooth(mutValues(1, j), round(0.001 * SAMPLE_RATE), "lowess");
    end
    mutValues = normalize_signal(mutValues, mutValuesPeak, "all");
    out = out + (out .* mutValues);
end
