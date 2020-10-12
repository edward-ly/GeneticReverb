function out = crossover(in, SELECTION_SIZE, POPULATION_SIZE)
% CROSSOVER Generate children and replace least fit individuals.
%
% Input arguments:
% in = input population
% SELECTION_SIZE = number of impulse responses to keep per generation
% POPULATION_SIZE = number of impulse responses
% NUM_SAMPLES = length in samples of each impulse response
%
% Output arguments:
% out = output population
%
% Current algorithm: weighted average of the parents where the weights are
% random for each individual.
%
  % Require all arguments
  if nargin < 3, error('Not enough input arguments.'); end
  if nargout < 1, error('Not enough output arguments.'); end

  % =========================================================================

  out = in;

  for i = (SELECTION_SIZE + 1):POPULATION_SIZE
    parents = randperm(SELECTION_SIZE, 2);
    p1 = in(:, parents(1));
    p2 = in(:, parents(2));
    w = rand;

    out(:, i) = (w .* p1) + ((1 - w) .* p2);
  end
end
