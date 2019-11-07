function out = genetic_rir(gaParams, irParams)
% GENETIC_RIR Generates a random impulse response with the given parameters.
% Function equivalent of main.m script for real-time processing.
%
% Input arguments:
% gaParams = struct containing genetic algorithm parameters
%     POPULATION_SIZE = IR population count
%     SELECTION_SIZE = IR selection count
%     NUM_GENERATIONS = no. of gens
%     STOP_GENERATIONS = no. of gens before stopping if no new IR found
%     FITNESS_THRESHOLD = fitness value threshold
%     MUTATION_RATE = mutation probability
% irParams = struct containing impulse response parameters
%     SAMPLE_RATE = sample rate of impulse response
%     T60 = T60 decay time (s)
%     ITDG = initial time delay gap (s)
%     EDT = early decay time (s)
%     C80 = clarity (dB)
%     BR = bass ratio
%
% Output arguments:
% out = row vector containing the impulse response
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % Calculate number of samples to record for impulse response
    numSamples = round(2 * irParams.T60 * irParams.SAMPLE_RATE);

    %-----------------------------------------------------------------------

    % Initialize population
    irPopulation = init_pop(numSamples, gaParams.POPULATION_SIZE, ...
        irParams.SAMPLE_RATE, irParams.T60);
    irFitness = Inf(gaParams.POPULATION_SIZE, 1);
    irBest = zeros(numSamples, 1);
    irBestFitness = Inf;
    currentGen = 0;
    currentStopGen = 0;

    while true
        % Evaluate population
        for i = 1:gaParams.POPULATION_SIZE
            irFitness(i) = fitness(irPopulation(:, i), irParams);
        end

        % Sort population by fitness value and update best individual
        [irPopulation, irFitness] = sort_pop(irPopulation, irFitness);
        if irFitness(1) < irBestFitness
            irBestFitness = irFitness(1);
            irBest = irPopulation(:, 1);
            currentStopGen = 0;
        else
            currentStopGen = currentStopGen + 1;
        end

        % Stop if fitness value is within threshold
        if irBestFitness < gaParams.FITNESS_THRESHOLD, break; end

        % Stop if fitness value is not updated after some number of generations
        if currentStopGen >= gaParams.STOP_GENERATIONS, break; end

        % Go to next generation (or stop if max number of generations reached)
        currentGen = currentGen + 1;
        if currentGen > gaParams.NUM_GENERATIONS, break; end

        % Select best individuals and generate children to replace remaining
        % individuals
        irPopulation = crossover(irPopulation, gaParams.SELECTION_SIZE, ...
            gaParams.POPULATION_SIZE, numSamples);

        % Mutate entire population
        irPopulation = mutate(irPopulation, gaParams.MUTATION_RATE);
    end

    %-----------------------------------------------------------------------

    % Transform to row vector
    out = irBest';
end
