function pop = init_pop(gaParams, irParams)
% INIT_POP Generate an initial population.
%
% Input arguments:
% gaParams = struct containing genetic algorithm parameters
% irParams = struct containing impulse response parameters
%
% Output arguments:
% pop = output population
%
% Current algorithm: randomly generate IRs from an array of random values from
% the normal distribution (mean = 0, std = 0.2).
% Then, keep some samples (and discard others) with some probability, which
% increases as time increases (to simulate density of early vs. late
% reflections).
% Finally, apply exponential decay to simulate sound absorption.
% The density of samples and rate of decay is random for each individual. Thus,
% the T60 of each impulse response will vary around the specified T60.
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    fs = irParams.SAMPLE_RATE;
    beta = irParams.T60;
    n = irParams.NUM_SAMPLES;
    popSize = gaParams.POPULATION_SIZE;

    % =========================================================================

    sampleDensity = rand(1, popSize) * 0.3 + 0.6; % {'lin', 0.6, 0.9}
    sampleDensity = repmat(sampleDensity, n, 1);

    decayRate = rand(1, popSize) * 2e-4 + 2e-4; % {'lin', 2e-4, 4e-4}
    decayRate = repmat(decayRate, n, 1);

    t = repmat((1:n)', 1, popSize) ./ fs;

    decayAmount = decayRate .^ (t / beta);

    sampleProbability = 1 - sampleDensity .^ t;
    sampleOccurences = rand(n, popSize) < sampleProbability;

    ITDGsample = round(irParams.ITDG * fs);
    sampleOccurences(1:ITDGsample, :) = 0; % no reflections before ITDG time
    sampleOccurences(ITDGsample + 1, :) = 1; % make reflection at ITDG time

    pop = randn(n, popSize) * 0.2;
    pop = pop .* sampleOccurences .* decayAmount;
    pop(1, :) = 0.99; % normalize first reflection at t = 0
end
