function [f, loss] = fitness(ir, params)
% FITNESS Calculate fitness value of impulse response.
%
% Input arguments:
% ir = column vector containing impulse response
% params = struct containing impulse response parameters
%     SAMPLE_RATE = sample rate of impulse response
%     NUM_SAMPLES = length of recorded impulse response (samples)
%     T60 = T60 decay time (s)
%     EDT = early decay time (s)
%     C80 = clarity (dB)
%     BR = bass ratio
%
% Output arguments:
% f = fitness value of impulse response
% loss = struct containing error/difference values for each parameter (optional)
%
    % Require all input arguments and fitness value output
    if nargin < 2, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % =========================================================================

    % Initialize loss output
    loss = params;

    % Copy sample rate to new variable (to shorten name)
    sampleRate = params.SAMPLE_RATE;

    % Calculate Schroeder curve of impulse response
    [irEDC, irEDCdB] = schroeder(ir);

    % =========================================================================

    % T60
    % Calculate T30 (time from -5 to -35 dB) and multiply by 2
    irEDCMaxLevel = irEDCdB(1);
    ir5dBSample = find(irEDCdB - irEDCMaxLevel < -5, 1);
    if isempty(ir5dBSample), f = Inf; return; end
    ir35dBSample = find(irEDCdB - irEDCMaxLevel < -35, 1);
    if isempty(ir35dBSample), f = Inf; return; end
    irT60 = (ir35dBSample - ir5dBSample) * 2 / sampleRate;

    % EDT (early decay time, i.e. time from 0 to -10 dB)
    ir10dBSample = find(irEDCdB - irEDCMaxLevel < -10, 1);
    if isempty(ir10dBSample), f = Inf; return; end
    irEDT = (ir10dBSample - 1) / sampleRate;

    % C80 (clarity)
    sample_80ms = round(0.08 * sampleRate) + 1;
    if sample_80ms >= numel(ir), f = Inf; return; end
    earlyEnergy = irEDC(1) - irEDC(sample_80ms);
    lateEnergy  = irEDC(sample_80ms);
    if lateEnergy <= 0, f = Inf; return; end
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    % BR (bass ratio)
    % Find amount of energy in 125 - 500Hz and 500Hz - 2000Hz bands and
    % calculate the ratio between the two
    irfft = abs(fft(ir));
    f125 = ceil(125 * length(irfft) / sampleRate) + 1;
    f500 = ceil(500 * length(irfft) / sampleRate);
    f2000 = floor(2000 * length(irfft) / sampleRate) + 1;
    lowContent = irfft(f125:f500);
    highContent = irfft((f500 + 1):f2000);
    lowEnergy = sum(lowContent .* lowContent);
    highEnergy = sum(highContent .* highContent);
    % Divide highEnergy by 4 to compensate for the fact that the highFrequency
    % bin is 4 times as wide
    highEnergy = highEnergy / 4;
    irBR = lowEnergy / highEnergy;
    
    % =========================================================================

    % Calculate mean squared error fitness value
    loss.T60  = irT60(1)  - params.T60;
    loss.EDT  = irEDT(1)  - params.EDT;
    loss.C80  = irC80(1)  - params.C80;
    loss.BR   = irBR(1)   - params.BR;
    f = (loss.T60 * loss.T60) + ...
        (loss.EDT * loss.EDT) + ...
        (loss.C80 * loss.C80) + ...
        (loss.BR * loss.BR);
    f = f / 4.0;
end
