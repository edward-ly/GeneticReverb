function [irBest, irBestFitness, fitnessCurve, loss, condition] = ...
  genetic_rir(gaParams, irParams, verbose)
% GENETIC_RIR Generates a random impulse response with the given parameters.
%
% Input arguments:
% gaParams = struct containing genetic algorithm parameters
%   POPULATION_SIZE = IR population count
%   SELECTION_SIZE = IR selection count
%   NUM_GENERATIONS = no. of gens
%   PLATEAU_LENGTH = no. of gens before stopping if no new IR found
%   FITNESS_THRESHOLD = fitness value threshold
%   MUTATION_RATE = mutation probability
% irParams = struct containing impulse response parameters
%   SAMPLE_RATE = sample rate of impulse response
%   NUM_SAMPLES = length of recorded impulse response (samples)
%   PREDELAY = Predelay time (samples), used for calculating C80
%   T60 = T60 decay time (s)
%   EDT = early decay time (s)
%   C80 = clarity (dB)
%   BR = bass ratio
% verbose = print status messages to command window (default: false)
%
% Output arguments:
% irBest = column vector containing the best impulse response
% irBestFitness = fitness value of impulse response returned
% fitnessCurve = column vector recording best fitness values after each
%   generation (optional)
% loss = struct containing error/difference values for each parameter (optional)
% condition = ['threshold', 'plateau', 'limit'] terminating condition that was
% reached when genetic algorithm ends
%
  % Require IR and GA arguments
  if nargin < 2, error('Not enough input arguments.'); end
  if nargout < 1, error('Not enough output arguments.'); end

  % Set missing input arguments
  if nargin < 3, verbose = false; end

  % =========================================================================

  % Initialize population
  if verbose, fprintf('Initializing population...\n'); end
  irPopulation = init_pop(gaParams, irParams);
  irBest = zeros(irParams.NUM_SAMPLES, 1);
  irBestFitness = Inf;
  currentGen = 0;
  currentPlatLen = 0;

  if nargout > 2, fitnessCurve = NaN(gaParams.NUM_GENERATIONS + 1, 1); end
  loss = struct('T60', 0, 'EDT', 0, 'C80', 0, 'BR', 0, ...
    'zT60', 0, 'zEDT', 0, 'zC80', 0, 'zBR', 0);
  stddev = struct('T60', 0, 'EDT', 0, 'C80', 0, 'BR', 0);

  while true
    % Evaluate population
    [irFitness, irLoss, stddev] = ...
      fitness(irPopulation, irParams, gaParams.POPULATION_SIZE, stddev);

    % Sort population by fitness value and update best individual
    [irPopulation, irFitness, irLoss] = ...
      sort_pop(irPopulation, irFitness, irLoss);

    if irFitness(1) < irBestFitness
      irBestFitness = irFitness(1);
      irBest = irPopulation(:, 1);
      loss = struct( ...
        'T60', irLoss.T60(1), ...
        'EDT', irLoss.EDT(1), ...
        'C80', irLoss.C80(1), ...
        'BR', irLoss.BR(1), ...
        'zT60', irLoss.zT60(1), ...
        'zEDT', irLoss.zEDT(1), ...
        'zC80', irLoss.zC80(1), ...
        'zBR', irLoss.zBR(1));
      currentPlatLen = 0;
    else
      currentPlatLen = currentPlatLen + 1;
    end

    % Record best fitness value this generation
    if nargout > 2
      fitnessCurve(currentGen + 1) = irBestFitness;
    end

    if verbose
      fprintf('Generation %d: best fitness value %d\n', ...
        currentGen, irBestFitness);
    end

    % Stop if fitness value is within threshold
    if irBestFitness < gaParams.FITNESS_THRESHOLD
      if verbose, fprintf('Optimal solution found.\n'); end
      condition = "Threshold";
      break
    end

    % Stop if fitness value is not updated after some number of generations
    if currentPlatLen >= gaParams.PLATEAU_LENGTH
      if verbose, fprintf('Local optimal solution found.\n'); end
      condition = "Plateau";
      break
    end

    % Go to next generation (or stop if max number of generations reached)
    currentGen = currentGen + 1;
    if currentGen > gaParams.NUM_GENERATIONS
      if verbose, fprintf('Maximum number of generations reached.\n'); end
      condition = "Generations";
      break
    end

    % Select best individuals and generate children to replace remaining
    % individuals
    irPopulation = crossover(irPopulation, gaParams.SELECTION_SIZE, ...
      gaParams.POPULATION_SIZE);

    % Mutate entire population
    irPopulation = mutate(irPopulation, gaParams.MUTATION_RATE);
  end

  if verbose
    fprintf('Diff: T60 = %f, EDT = %f, C80 = %f, BR = %f\n', ...
      loss.T60, loss.EDT, loss.C80, loss.BR);
    fprintf('Z-Diff: T60 = %f, EDT = %f, C80 = %f, BR = %f\n', ...
      loss.zT60, loss.zEDT, loss.zC80, loss.zBR);
    fprintf('Dev: T60 = %f, EDT = %f, C80 = %f, BR = %f\n', ...
      stddev.T60, stddev.EDT, stddev.C80, stddev.BR);
  end
end
