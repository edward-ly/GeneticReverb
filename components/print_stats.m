function print_stats(NUM_IRS, times, fitnesses, losses, conditions, quality, T60)
% PRINT_STATS Write statistics from evaluation scripts to command window
%
% Input arguments:
% NUM_IRS = number of IRs to generate per iteration
% times = computation times of each impulse response
% fitnesses = fitness values of each impulse response
% losses = struct containing arrays of parameter error values
% conditions = array of termininating conditions reached for each IR
% quality = quality setting of current iteration
% T60 = T60 time of current iteration, if applicable
%
  % Require all arguments except T60
  if nargin < 6, error('Not enough input arguments.'); end

  fprintf('....................\n');
  if nargin < 7
    fprintf('Summary (%s Settings):\n', quality);
  else
    fprintf('Summary (%s Settings, T60 = %f):\n', quality, T60);
  end
  fprintf('Run Time: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(times), median(times), max(times), mean(times), std(times));
  fprintf('Fitness: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(fitnesses), median(fitnesses), max(fitnesses), mean(fitnesses), std(fitnesses));
  fprintf('T60 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([losses.T60]), median([losses.T60]), max([losses.T60]), mean([losses.T60]), std([losses.T60]));
  fprintf('EDT Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([losses.EDT]), median([losses.EDT]), max([losses.EDT]), mean([losses.EDT]), std([losses.EDT]));
  fprintf('C80 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([losses.C80]), median([losses.C80]), max([losses.C80]), mean([losses.C80]), std([losses.C80]));
  fprintf('BR Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([losses.BR]), median([losses.BR]), max([losses.BR]), mean([losses.BR]), std([losses.BR]));

  counts = [sum(strcmp(conditions, 'Generations')), ...
    sum(strcmp(conditions, 'Plateau')), ...
    sum(strcmp(conditions, 'Threshold'))];

  fprintf('\nTerminating conditions:\n');
  fprintf('Generations: %i (%.0f%%)\n', counts(1), counts(1) * 100 / NUM_IRS);
  fprintf('Plateau: %i (%.0f%%)\n', counts(2), counts(2) * 100 / NUM_IRS);
  fprintf('Threshold: %i (%.0f%%)\n', counts(3), counts(3) * 100 / NUM_IRS);
  fprintf('\n');
end
