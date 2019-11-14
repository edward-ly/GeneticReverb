function [times, fitnesses, lossesStruct] = ir_test(gaParams, T60, NUM_IRS)
% IR_TEST Generate IRs and return details about each impulse response.
% For evaluation purposes only.
%
% Input arguments:
% gaParams = struct containing genetic algorithm parameters
% T60 = desired T60 of impulse response (s)
% NUM_IRS = number of impulse responses to generate
%
% Output arguments:
% times = computation times of each impulse response
% fitnesses = fitness values of each impulse response
% losses = struct containing arrays of parameter error values
%
    % Require all arguments
    if nargin < 3, error('Not enough input arguments.'); end
    if nargout < 3, error('Not enough output arguments.'); end

    times = zeros(NUM_IRS, 1);
    fitnesses = zeros(NUM_IRS, 1);
    % Define irParams struct
    irParams = struct( ...
        'SAMPLE_RATE', 16000, ...
        'NUM_SAMPLES', 0, ...
        'T60', 0, ...
        'EDT', 0, ...
        'ITDG', 0, ...
        'C80', 0, ...
        'BR', 0);
    lossesStruct = repmat(irParams, NUM_IRS, 1);

    for i = 1:NUM_IRS
        timer = tic;
        [~, fitnesses(i), ~, lossesStruct(i)] = ...
            genetic_rir(gaParams, rand_ir_params(T60), false);
        times(i) = toc(timer);

        if mod(i, ceil(NUM_IRS / 20)) == 0, fprintf('.'); end
    end

    losses = struct( ...
        'T60', zeros(1, NUM_IRS), ...
        'EDT', zeros(1, NUM_IRS), ...
        'ITDG', zeros(1, NUM_IRS), ...
        'C80', zeros(1, NUM_IRS), ...
        'BR', zeros(1, NUM_IRS));

    for i = 1:NUM_IRS
        losses.T60(i)  = lossesStruct(i).T60;
        losses.EDT(i)  = lossesStruct(i).EDT;
        losses.ITDG(i) = lossesStruct(i).ITDG;
        losses.C80(i)  = lossesStruct(i).C80;
        losses.BR(i)   = lossesStruct(i).BR;
    end

    fprintf('\n');
end

