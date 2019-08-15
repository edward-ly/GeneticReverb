function [sortedPop, sortedFitness] = sort_pop(pop, fitness)
% POP_SORT Sort population by fitness value.
%
% Input arguments:
% pop = unsorted population
% fitness = fitness values of unsorted population
%
% Output arguments:
% sortedPop = sorted population
% sortedFitness = fitness values of sorted population
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % Output argument sortedFitness is optional
    if nargout < 1, error('Not enough output arguments.'); end

    [sortedFitness, indices] = sort(fitness);
    sortedPop = pop;
    for i = 1:numel(indices)
        sortedPop(:, i) = pop(:, indices(i));
    end
end
