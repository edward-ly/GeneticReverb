function out = resample_ir(plugin, in, sampleRate)
% RESAMPLE_IR Resamples and extends IR to specified sample rate and length
%
% Input arguments:
% plugin = plugin object containing resampler system objects and buffer length
% in = row vector containing the input impulse response
% sampleRate = new sample rate
%
% Output arguments:
% out = row vector containing the resampled impulse response
%
    % Require all arguments
    if nargin < 3, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % Initialize constant-length input for resamplers
    input = zeros(plugin.BUFFER_LENGTH, 1);
    if length(in) > plugin.BUFFER_LENGTH
        input = in(1:plugin.BUFFER_LENGTH)';
    else
        input(1:length(in)) = in';
    end

    if plugin.RESAMPLE
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
        else
            % No conversion for unsupported sample rates
            output = in';
        end
    else
        output = in';
    end

    % Set output length to buffer length again
    out = zeros(1, plugin.BUFFER_LENGTH);
    if length(output) > plugin.BUFFER_LENGTH
        out = output(1:plugin.BUFFER_LENGTH)';
    else
        out(1:length(output)) = output';
    end
end
