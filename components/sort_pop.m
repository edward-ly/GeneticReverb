function [sortedPop, sortedFitness, sortedLoss] = sort_pop(pop, fitness, loss)
% POP_SORT Sort population by fitness value.
%
% Input arguments:
% pop = unsorted population
% fitness = fitness values of unsorted population
% loss = vector of structs containing detailed error values
%
% Output arguments:
% sortedPop = sorted population
% sortedFitness = fitness values of sorted population
% sortedLoss = detailed error values of sorted population
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % Output argument sortedFitness is optional
    if nargout < 1, error('Not enough output arguments.'); end

    [sortedFitness, indices] = sort(fitness);
    sortedPop = pop(:, indices);
    sortedLoss = loss(indices);
end
