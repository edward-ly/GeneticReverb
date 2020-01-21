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
    % Require all input arguments
    if nargin < 3, error('Not enough input arguments.'); end

    % Output argument sortedFitness is optional
    if nargout < 1, error('Not enough output arguments.'); end

    % =========================================================================

    [sortedFitness, indices] = sort(fitness);
    sortedPop = pop(:, indices);
    sortedLoss.T60 = loss.T60(indices);
    sortedLoss.EDT = loss.EDT(indices);
    sortedLoss.C80 = loss.C80(indices);
    sortedLoss.BR = loss.BR(indices);
end
