function out = genetic_rir (SAMPLE_RATE, T60, ITDG, EDT, C80, BR)
%GENETIC_RIR Generates a random impulse response with the given parameters.
% Function equivalent of main.m script for real-time processing.
%
% Input arguments:
% SAMPLE_RATE = sample rate of impulse response
% T60 = T60 decay time (s)
% ITDG = initial time delay gap (s)
% EDT = early decay time (s)
% C80 = clarity (dB)
% BR = bass ratio
%
% Output arguments:
% out = row vector containing the impulse response
%
    % Require all arguments
    if nargin < 6, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % Genetic algorithm parameters
    POPULATION_SIZE = 5;
    SELECTION_SIZE = 2;
    NUM_GENERATIONS = 1;
    STOP_GENERATIONS = 1;
    FITNESS_THRESHOLD = 1e-2;
    MUTATION_RATE = 0.001;

    % Impulse response parameters
    NUM_SAMPLES = round(2 * T60 * SAMPLE_RATE);

    %-----------------------------------------------------------------------

    % Initialize population
    irPopulation = init_pop(NUM_SAMPLES, POPULATION_SIZE, SAMPLE_RATE, T60);
    irFitness = Inf(POPULATION_SIZE, 1);
    irBest = zeros(NUM_SAMPLES, 1);
    irBestFitness = Inf;
    currentGen = 0;
    currentStopGen = 0;

    while true
        % Evaluate population
        for i = 1:POPULATION_SIZE
            irFitness(i) = fitness( ...
                irPopulation(:, i), SAMPLE_RATE, T60, ITDG, EDT, C80, BR);
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
        if irBestFitness < FITNESS_THRESHOLD, break; end

        % Stop if fitness value is not updated after some number of generations
        if currentStopGen >= STOP_GENERATIONS, break; end

        % Go to next generation (or stop if max number of generations reached)
        currentGen = currentGen + 1;
        if currentGen > NUM_GENERATIONS, break; end

        % Select best individuals and generate children to replace remaining
        % individuals
        irPopulation = crossover(irPopulation, SELECTION_SIZE, ...
            POPULATION_SIZE, NUM_SAMPLES);

        % Mutate entire population
        irPopulation = mutate(irPopulation, MUTATION_RATE);
    end

    %-----------------------------------------------------------------------

    % Normalize IR for more consistent gain and to prevent clipping
    irBest = normalize_signal(irBest, 0.99);

    % Transform to row vector
    out = irBest';
end
