function pop = init_pop(gaParams, irParams)
% INIT_POP Generate an initial population of impulse responses.
%
% Input arguments:
% gaParams = struct containing genetic algorithm parameters
% irParams = struct containing impulse response parameters
%
% Output arguments:
% pop = output population
%
% Current algorithm: simulate the conditions of real-world recorded IRs.
% (1) Generate Gaussian (white) noise and reduce its gain by a random factor.
% (2) Take some samples at random and manually change the values of these
% samples. The probability of a sample at time t being chosen increases as t
% increases (to simulate density of early vs. late reflections), and the new
% values of these samples are randomly generated from a normal distribution
% (mean = 1, std = 0.05), along with a 50% probability of each of these samples
% changing sign.
% (3) Apply exponential decay to the signal to simulate sound absorption (the
% rate of which is inversely proportional to the input T60 value).
% (4) Apply a band-pass filter (constant 6 dB/octave rolloff at both ends of the
% band, while the cutoff frequencies are random).
% (5) Add a small amount of low-pass Gaussian noise (gain is within noise floor,
% with a cutoff frequency of 250 Hz and 12 dB/octave rolloff for the low-pass
% filter).
%
  % Require all arguments
  if nargin < 2, error('Not enough input arguments.'); end
  if nargout < 1, error('Not enough output arguments.'); end

  fs = irParams.SAMPLE_RATE;
  T60 = irParams.T60;
  n = irParams.NUM_SAMPLES;
  popSize = gaParams.POPULATION_SIZE;

  % =========================================================================

  sampleDensity = rand(1, popSize) * 0.5 + 0.2; % {'lin', 0.2, 0.7}
  sampleDensity = repmat(sampleDensity, n, 1);

  decayRate = rand(1, popSize) * 2e-4 + 2e-4; % {'lin', 2e-4, 4e-4}
  decayRate = repmat(decayRate, n, 1);

  t = repmat((1:n)', 1, popSize) ./ fs;

  decayAmount = decayRate .^ (t / T60);

  sampleProbability = 1 - sampleDensity .^ t;
  sampleOccurences = rand(n, popSize) < sampleProbability;
  sampleOccurences(1, :) = true; % ensure first sample is a reflection
  sampleSigns = (-1) .^ (rand(n, popSize) < 0.5);

  noise = randn(n, popSize) * (rand * 0.4 + 0.1); % {'lin', 0.1, 0.5}
  samples = randn(n, popSize) * 0.05 + 1;
  pop = (noise .* ~sampleOccurences) + ...
    (samples .* sampleOccurences .* sampleSigns);
  pop = pop .* decayAmount;

  for i = 1:popSize
    % Lower cutoff frequency: 31.25-500 Hz
    % Higher cutoff frequency: 500-8000 Hz
    [b, a] = butter(1, 500 .* [2^(rand * 4 - 4) 2^(rand * 4)] ./ (fs/2));
    pop(:, i) = filter(b, a, pop(:, i));
  end

  bg_noise = randn(n, popSize) * 0.0003;
  [b, a] = butter(2, 250/(fs/2));
  bg_noise = filter(b, a, bg_noise);
  pop = pop + bg_noise;
end
