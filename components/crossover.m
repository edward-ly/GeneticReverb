function out = crossover(in, SELECTION_SIZE, POPULATION_SIZE)
% CROSSOVER Generate children and replace least fit individuals.
% out = output population
% in = input population
% Current algorithm: replace each worst individual with the weighted average of
% two random parents from the selection pool.
% The weights are random for each crossover.
    out = in;
    for i = (SELECTION_SIZE + 1):POPULATION_SIZE
        parents = randperm(SELECTION_SIZE, 2);
        weight = rand;
        parent1 =      weight  .* in(:, parents(1));
        parent2 = (1 - weight) .* in(:, parents(2));
        out(:, i) = parent1 + parent2;
    end
end
