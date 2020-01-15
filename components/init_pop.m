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

    sampleDensity = rand(1, popSize) .^ 2 * 2 + 1.5; % {'pow', 2, 1.5, 3.5}
    sampleDensity = repmat(sampleDensity, n, 1);

    decayAmount = rand(1, popSize) .^ 2 * 2 + 1.5; % {'pow', 2, 1.5, 3.5}
    decayTime = round(0.0425 * decayAmount * fs);
    decayTime = repmat(decayTime, n, 1);

    index = (-1:-1:(-1 * n))' / beta;
    index = repmat(index, 1, popSize) ./ decayTime;

    decayRate = decayAmount .^ index;

    sampleProbability = 1 - sampleDensity .^ (0.035 * index);
    sampleOccurences = rand(n, popSize) < sampleProbability;

    ITDGsample = round(irParams.ITDG * fs);
    sampleOccurences(1:ITDGsample, :) = 0; % no reflections before ITDG time
    sampleOccurences(ITDGsample + 1, :) = 1; % ensure reflection at ITDG time

    pop = randn(n, popSize) * 0.2;
    pop = pop .* sampleOccurences .* decayRate;
    pop(1, :) = 0.99; % normalize first reflection at t = 0
end
