function out = shelf_filt(in, warmth, sampleRate)
% SHELF_FILT Applies low-shelf EQ to IR(s) given plugin parameters
%
% Input arguments:
% in = column vector/matrix containing impulse response(s)
% warmth = warmth parameter value of plugin
% sampleRate = sample rate of impulse response(s)
%
% Output arguments:
% out = column vector/matrix containing filtered impulse response(s)
%
    % Require input arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % Do nothing if slope == 0
    if warmth == 50, out = in; return; end

    % Get SOS IIR filter coefficients for low-shelf EQ
    EQGain = warmth * 0.24 - 12;
    EQSlope = abs(warmth / 50 - 1);
    fc = 500 / (sampleRate / 2); % center frequency = 500 Hz
    [B, A] = designShelvingEQ(EQGain, EQSlope, fc);
    SOSMatrix = [B', [1, A']];

    out = sosfilt(SOSMatrix, in);
end
