function [sortedPop, sortedFitness] = sort_pop(pop, fitness)
% POP_SORT Sort population by fitness value.
% sortedPop = sorted population
% sortedFitness = fitness values of sorted population
% pop = unsorted population
% fitness = fitness values of unsorted population
    [sortedFitness, indices] = sort(fitness);
    sortedPop = pop;
    for i = 1:numel(indices)
        sortedPop(:, i) = pop(:, indices(i));
    end
end
