function params = rand_ir_params(T60)
% RAND_IR_PARAMS Return random parameters for impulse response.
% For evaluation purposes only.
%
% Input arguments:
% T60 = desired T60 of impulse response (s)
%
% Output arguments:
% params = struct containing impulse response parameters
%
    % Require input argument
    if nargin < 1, error('Not enough input arguments.'); end

    params = struct( ...
        'SAMPLE_RATE', 16000, ...
        'NUM_SAMPLES', 0, ...
        'T60', T60, ...
        'EDT', 0.01 * (100 ^ rand), ...   % 0.01 to 1 s (log)
        'ITDG', rand * 0.5, ...           % 0 to 0.5 s (lin)
        'C80', rand * 10 - 5, ...         % -5 to 5 dB (lin)
        'BR', 0.25 * (16 ^ rand));        % 0.25 to 4 (log)

    params.NUM_SAMPLES = ceil(1.5 * params.T60 * params.SAMPLE_RATE);
end

