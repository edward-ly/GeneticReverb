function out = mutate(in, MUTATION_RATE)
% MUTATE Changes the population's values with some probability.
% out = output population
% in = input population
% Current algorithm: for each affected sample, add to its value a random
% number from the normal distribution (std. dev. 0.1).
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end

    out = in;
    [I, J] = size(out);
    mutValues = double(rand(I, J) < MUTATION_RATE) .* (randn(I, J) * 0.1);
    out = out + out .* mutValues;
end
