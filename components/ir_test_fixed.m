function [times, fitnesses, lossesStruct, conditions] = ...
  ir_test_fixed(irParams, gaParams, NUM_IRS)
% IR_TEST_FIXED Generate IRs and return details about each impulse response.
% For evaluation purposes only.
%
% Input arguments:
% irParams = struct containing impulse response parameters
% gaParams = struct containing genetic algorithm parameters
% NUM_IRS = number of impulse responses to generate
%
% Output arguments:
% times = computation times of each impulse response
% fitnesses = fitness values of each impulse response
% losses = struct containing arrays of parameter error values
% conditions = array of termininating conditions reached for each IR
%
  % Require all arguments
  if nargin < 3, error('Not enough input arguments.'); end
  if nargout < 3, error('Not enough output arguments.'); end

  % =========================================================================

  times = zeros(NUM_IRS, 1);
  fitnesses = zeros(NUM_IRS, 1);
  % Define params struct
  lossesElement = struct( ...
    'T60', 0, ...
    'EDT', 0, ...
    'C80', 0, ...
    'BR', 0, ...
    'zT60', 0, ...
    'zEDT', 0, ...
    'zC80', 0, ...
    'zBR', 0);
  lossesStruct = repmat(lossesElement, NUM_IRS, 1);
  conditions = strings(NUM_IRS, 1);

  parfor i = 1:NUM_IRS
    timer = tic;
    [~, fitnesses(i), ~, lossesStruct(i), conditions(i)] = ...
      genetic_rir(gaParams, irParams, false);
    times(i) = toc(timer);
  end

  losses = struct( ...
    'T60', zeros(NUM_IRS, 1), ...
    'EDT', zeros(NUM_IRS, 1), ...
    'C80', zeros(NUM_IRS, 1), ...
    'BR', zeros(NUM_IRS, 1), ...
    'zT60', zeros(NUM_IRS, 1), ...
    'zEDT', zeros(NUM_IRS, 1), ...
    'zC80', zeros(NUM_IRS, 1), ...
    'zBR', zeros(NUM_IRS, 1));

  for i = 1:NUM_IRS
    losses.T60(i)  = lossesStruct(i).T60;
    losses.EDT(i)  = lossesStruct(i).EDT;
    losses.C80(i)  = lossesStruct(i).C80;
    losses.BR(i)   = lossesStruct(i).BR;
    losses.zT60(i) = lossesStruct(i).zT60;
    losses.zEDT(i) = lossesStruct(i).zEDT;
    losses.zC80(i) = lossesStruct(i).zC80;
    losses.zBR(i)  = lossesStruct(i).zBR;
  end
end
