function [ sorted_pop, sorted_fitness ] = pop_sort( pop, fitness )
% POP_SORT Sort population by fitness value.
% sorted_pop = sorted population
% sorted_fitness = fitness values of sorted population
% pop = unsorted population
% fitness = fitness values of unsorted population
    [ sorted_fitness, indices ] = sort(fitness);
    sorted_pop = pop;
    for i = 1:numel(indices)
        sorted_pop( :, :, i ) = pop( :, :, indices( 1, i ) );
    end
end
