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

    % =========================================================================

    params = struct( ...
        'SAMPLE_RATE', 16000, ...
        'NUM_SAMPLES', 0, ...
        'T60', T60, ...
        'EDT', 0, ...
        'C80', rand * 30 - 15, ...           % -15 to 15 dB (lin)
        'BR', rand * 10 - 5);                % -5 to 5 dB (lin)

    params.NUM_SAMPLES = ceil(1.5 * params.T60 * params.SAMPLE_RATE);
    params.EDT = (rand * 20 + 5) * params.T60 / 100.0; % 5 to 25 percent of T60
end
