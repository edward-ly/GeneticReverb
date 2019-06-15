function out_pop = mutate( in_pop, MUTATION_RATE )
% MUTATE Changes the population's values with some probability.
% out_pop = output population
% in_pop = input population
% Current algorithm: for each affected sample,
% add to it a random number from the normal distribution
% (standard deviation = 0.05).
    out_pop = in_pop;
    [ I, J, K ] = size(out_pop);
    mut_values = double( rand( I, J, K ) < MUTATION_RATE ) .* randn( I, J, K ) .* 0.1;
    out_pop = out_pop + mut_values;
end
