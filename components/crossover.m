function out_pop = crossover( in_pop, SELECTION_SIZE, POPULATION_SIZE )
% CROSSOVER Generate children and replace least fit individuals.
% out_pop = output population
% in_pop = input population
% Current algorithm: replace each worst individual with the weighted
% average of two random parents from the selection pool.
% The weights are random for each crossover.
    out_pop = in_pop;
    for i = ( SELECTION_SIZE + 1 ):POPULATION_SIZE
        parents = randperm( SELECTION_SIZE, 2 );

        weight = rand;
        parent1 = weight .* in_pop( :, :, parents(1) );
        parent2 = ( 1 - weight ) .* in_pop( :, :, parents(2) );
        out_pop( :, :, i ) = parent1 + parent2;
    end
end
