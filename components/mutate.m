function out = mutate(in, MUTATION_RATE)
% MUTATE Changes the population's values with some probability.
%
% Input arguments:
% in = input population
% MUTATION_RATE = probability of each sample changing value
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
  if nargin < 2, error('Not enough input arguments.'); end
  if nargout < 1, error('Not enough output arguments.'); end

  % =========================================================================

  out = in;
  [I, J] = size(out);

  mutPoints = rand(I, J) < MUTATION_RATE;
  mutPoints(1, :) = 0; % do not mutate initial reflection
  mutValues = mutPoints .* randn(I, J) ./ norminv(0.75);
  out = (out .* ~mutPoints) + (out .* mutValues);
end
