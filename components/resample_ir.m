function out = resample_ir(plugin, in, sampleRate)
% RESAMPLE_IR Resamples and extends IR to specified sample rate and length
%
% Input arguments:
% plugin = plugin object containing resampler system objects and buffer length
% in = column vector containing the input impulse response
% sampleRate = new sample rate
%
% Output arguments:
% out = column vector containing the resampled impulse response
%
    % Require all arguments
    if nargin < 3, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % Initialize constant-length input for resamplers
    input = zeros(240000, 1);  % max length: 1.5 * 10s * 16000Hz
    input(1:length(in)) = in;

    if sampleRate == 44100
        output = step(plugin.pFIR44100, input);
    elseif sampleRate == 22050
        output = step(plugin.pFIR22050, input);
    elseif sampleRate == 32000
        output = step(plugin.pFIR32000, input);
    elseif sampleRate == 48000
        output = step(plugin.pFIR48000, input);
    elseif sampleRate == 88200
        output = step(plugin.pFIR88200, input);
    elseif sampleRate == 96000
        output = step(plugin.pFIR96000, input);
    elseif sampleRate == 192000
        output = step(plugin.pFIR192000, input);
    else
        % No conversion for unsupported sample rates
        output = in;
    end

    % Set output length to buffer length again
    out = zeros(plugin.NUM_SAMPLES, 1);
    if length(output) > plugin.NUM_SAMPLES
        out = output(1:plugin.NUM_SAMPLES);
    else
        out(1:length(output)) = output;
    end
end
