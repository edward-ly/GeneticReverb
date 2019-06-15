function out = mutate(in, MUTATION_RATE)
% MUTATE Changes the population's values with some probability.
% out = output population
% in = input population
% Current algorithm: for each affected sample, add to it a random number from
% the normal distribution (with standard deviation = 0.1).
    out = in;
    [I, J, K] = size(out);
    mutValues = double(rand(I, J, K) < MUTATION_RATE) .* randn(I, J, K) .* 0.1;
    out = out + mutValues;
end
