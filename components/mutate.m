function out = mutate(in, MUTATION_RATE)
% MUTATE Changes the population's values with some probability.
% out = output population
% in = input population
% Current algorithm: for each affected sample, multiply its value by a random
% positive factor from the standard normal distribution.
    out = in;
    [I, J] = size(out);
    mutValues = double(rand(I, J) < MUTATION_RATE) .* abs(randn(I, J));
    out = out .* mutValues;
end
