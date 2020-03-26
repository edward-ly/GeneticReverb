function out = mutate(in, MUTATION_RATE, ITDG)
% MUTATE Changes the population's values with some probability.
%
% Input arguments:
% in = input population
% MUTATION_RATE = probability of each sample changing value
% ITDG = index of sample at ITDG time
%
% Output arguments:
% out = output population
%
% Current algorithm: for each random sample, multiply its value by a random
% factor from the normal distribution (mean = 0, std = 1.4826). This gives a 50%
% chance of each sample increasing or decreasing in magnitude, as well as a 50%
% chance of each value being positive or negative.
%
    % Require all arguments
    if nargin < 3, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % =========================================================================

    out = in;
    [I, J] = size(out);

    mutPoints = rand(I, J) < MUTATION_RATE;
    mutValues = mutPoints .* randn(I, J) ./ norminv(0.75);
    mutValues(1:ITDG, :) = 0; % no mutations before ITDG time
    out = (out .* ~mutPoints) + (out .* mutValues);
end
