function out = genetic_rir (SAMPLE_RATE, T60, ITDG, EDT, C80, BR)
%GENETIC_RIR Function equivalent of main.m script for real-time processing.
% out = row vector containing the impulse response
    % Require all arguments
    if nargin < 6, error('Not enough input arguments.'); end

    % Genetic algorithm parameters
    POPULATION_SIZE = 5;
    SELECTION_SIZE = 2;
    NUM_GENERATIONS = 1;
    STOP_GENERATIONS = 1;
    FITNESS_THRESHOLD = 1e-2;
    MUTATION_RATE = 0.001;

    % Downsample IR for faster calculations
    IR_SAMPLE_RATE = SAMPLE_RATE;
    sampleFactor = 1;
    while IR_SAMPLE_RATE >= 32000
        IR_SAMPLE_RATE = IR_SAMPLE_RATE / 2;
        sampleFactor = sampleFactor * 2;
    end

    % Impulse response parameters
    NUM_SAMPLES = round(2 * T60 * IR_SAMPLE_RATE);

    % Initialize output
    out = zeros(1, 88200);

    %-----------------------------------------------------------------------

    % Initialize population
    irPopulation = init_pop(NUM_SAMPLES, POPULATION_SIZE, IR_SAMPLE_RATE, T60);
    irFitness = Inf(POPULATION_SIZE, 1);
    irBest = zeros(NUM_SAMPLES, 1);
    irBestFitness = Inf;
    currentGen = 0;
    currentStopGen = 0;

    while true
        % Evaluate population
        for i = 1:POPULATION_SIZE
            irFitness(i) = fitness( ...
                irPopulation(:, i), IR_SAMPLE_RATE, T60, ITDG, EDT, C80, BR);
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

    % Upsample back to audio sample rate
    irBest = upsample(irBest, sampleFactor);
    
    % Transform to row vector
    out(1:length(irBest)) = irBest';
end
