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

    % Pre-process parameter values
    % Map warmth values of 0-100% to bass ratio {'log', 0.25, 4}
    pBassRatio = 0.25 * 16 ^ (plugin.WARMTH / 100);

    % Struct for IR parameters
    irParams = struct( ...
        'SAMPLE_RATE', plugin.IR_SAMPLE_RATE, ...
        'T60', plugin.T60, ...
        'ITDG', plugin.ITDG, ...
        'EDT', plugin.EDT, ...
        'C80', plugin.C80, ...
        'BR', pBassRatio);

    if plugin.STEREO
        % Generate new impulse responses
        newIRLeft = genetic_rir(irParams);
        newIRRight = genetic_rir(irParams);

        % Modify gains of IRs so that RMS levels are equal
        irLeftRMS = rms(newIRLeft);
        irRightRMS = rms(newIRRight);
        newIRLeft = newIRLeft .* (1 + (irRightRMS / irLeftRMS));
        newIRRight = newIRRight .* (1 + (irLeftRMS / irRightRMS));

        % Normalize for consistent output gain and prevent clipping
        irPeak = max([max(abs(newIRLeft)) max(abs(newIRRight))]);
        newIRLeft = newIRLeft .* (0.99 / irPeak);
        newIRRight = newIRRight .* (0.99 / irPeak);

        % Resample/resize impulse responses, assign to output
        irLeft = resample_ir(plugin, newIRLeft, sampleRate);
        irRight = resample_ir(plugin, newIRRight, sampleRate);
    else
        % Generate new impulse response
        newIR = genetic_rir(irParams);

        % Normalize for consistent output gain and prevent clipping
        newIR = normalize_signal(newIR, 0.99);

        % Resample/resize impulse response
        ir = resample_ir(plugin, newIR, sampleRate);

        % Assign IR to both channels
        irLeft = ir; irRight = ir;
    end
end
