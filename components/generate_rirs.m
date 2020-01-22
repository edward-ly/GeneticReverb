function [irLeft, irRight] = generate_rirs(plugin, sampleRate)
% GENERATE_RIRS Generate new impulse responses for stereo plugin
%
% Input arguments:
% plugin = plugin object containing IR properties
% sampleRate = sample rate of plugin
%
% Output arguments:
% irLeft = impulse response assigned to left audio channel
% irRight = impulse response assigned to right audio channel
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end
    if nargout < 2, error('Not enough output arguments.'); end

    % =========================================================================

    % Pre-process parameter values
    % Convert ITDG to seconds
    pITDG = plugin.ITDG / 1000.0;
    % EDT should be equal to 1/6 of T60
    pEDT = plugin.T60 / 6.0;

    % Struct for IR parameters
    irParams = struct( ...
        'SAMPLE_RATE', plugin.IR_SAMPLE_RATE, ...
        'NUM_SAMPLES', plugin.IR_NUM_SAMPLES, ...
        'T60', plugin.T60, ...
        'ITDG', pITDG, ...
        'EDT', pEDT, ...
        'C80', plugin.C80, ...
        'BR', plugin.WARMTH);

    % Struct for GA parameters
    if plugin.QUALITY == Quality.high
        gaParams = struct( ...
            'POPULATION_SIZE', 20, ...
            'SELECTION_SIZE', 8, ...
            'NUM_GENERATIONS', 20, ...
            'PLATEAU_LENGTH', 5, ...
            'FITNESS_THRESHOLD', 1e-3, ...
            'MUTATION_RATE', 0.001);
    elseif plugin.QUALITY == Quality.medium
        gaParams = struct( ...
            'POPULATION_SIZE', 20, ...
            'SELECTION_SIZE', 8, ...
            'NUM_GENERATIONS', 10, ...
            'PLATEAU_LENGTH', 3, ...
            'FITNESS_THRESHOLD', 1e-3, ...
            'MUTATION_RATE', 0.001);
    else % plugin.QUALITY == Quality.low
        gaParams = struct( ...
            'POPULATION_SIZE', 10, ...
            'SELECTION_SIZE', 4, ...
            'NUM_GENERATIONS', 10, ...
            'PLATEAU_LENGTH', 3, ...
            'FITNESS_THRESHOLD', 1e-2, ...
            'MUTATION_RATE', 0.001);
    end

    if plugin.STEREO
        % Generate new impulse responses
        newIRs = zeros(irParams.NUM_SAMPLES, 2);
        for i = 1:2, newIRs(:, i) = genetic_rir(gaParams, irParams); end

        % Modify gains of IRs so that RMS levels are equal
        newIRsRMS = rms(newIRs);
        newIRs(:, 1) = newIRs(:, 1) .* (1 + (newIRsRMS(2) / newIRsRMS(1)));
        newIRs(:, 2) = newIRs(:, 2) .* (1 + (newIRsRMS(1) / newIRsRMS(2)));

        % Normalize to prevent clipping
        newIRs = normalize_signal(newIRs, 0.99);

        % Resample/resize impulse responses, assign to output
        irLeft = resample_ir(plugin, newIRs(:, 1), sampleRate)';
        irRight = resample_ir(plugin, newIRs(:, 2), sampleRate)';
    else
        % Generate new impulse response
        newIR = genetic_rir(gaParams, irParams);

        % Normalize to prevent clipping
        newIR = normalize_signal(newIR, 0.99);

        % Resample/resize impulse response
        ir = resample_ir(plugin, newIR, sampleRate)';

        % Assign IR to both channels
        irLeft = ir; irRight = ir;
    end

    % Calculate number of predelay samples
    delayLeft = round(plugin.L_DELAY * sampleRate / 1000);
    delayRight = round(plugin.R_DELAY * sampleRate / 1000);

    % Apply predelay
    irLeft = [zeros(1, delayLeft), irLeft(1:(end - delayLeft))];
    irRight = [zeros(1, delayRight), irRight(1:(end - delayRight))];
end
