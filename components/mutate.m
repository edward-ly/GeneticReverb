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
% Current algorithm: for each affected sample, add to its value a random
% number from the normal distribution (mean = 0, std = 0.1).
%
    % Require all arguments
    if nargin < 3, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    out = in;
    [I, J] = size(out);
    mutValues = double(rand(I, J) < MUTATION_RATE) .* (randn(I, J) * 0.1);
    mutValues(1:ITDG, :) = 0; % no mutations before ITDG time
    out = out + out .* mutValues;
end
