function [f, loss] = fitness(ir, params)
% FITNESS Calculate fitness value of impulse response.
%
% Input arguments:
% ir = column vector containing impulse response
% params = struct containing impulse response parameters
%     SAMPLE_RATE = sample rate of impulse response
%     NUM_SAMPLES = length of recorded impulse response (samples)
%     T60 = T60 decay time (s)
%     ITDG = initial time delay gap (s)
%     EDT = early decay time (s)
%     C80 = clarity (dB)
%     BR = bass ratio
%
% Output arguments:
% f = fitness value of impulse response
% loss = struct containing error/difference values for each parameter (optional)
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    %% Useful information for parameter calculations
    loss = params;

    % Copy sample rate to new variable (to shorten name)
    sampleRate = params.SAMPLE_RATE;

    % Get start time of IR (arrival of peak reflection)
    [~, irMaxIndex] = max(abs(ir));

    % Calculate Schroeder curve of impulse response
    [irEDC, irEDCdB] = schroeder(ir);

    %% Parameter calculations
    % ITDG (initial time delay gap)
    % Calculate time difference between first two arrivals
    irIndices = find(ir, 2);
    if numel(irIndices) < 2, f = Inf; return; end
    irITDG = (irIndices(2) - irIndices(1)) / sampleRate;

    % T60
    % Calculate T30 (time from -5 to -35 dB) and multiply by 2
    irEDCMaxLevel = irEDCdB(irMaxIndex);
    ir5dBSample = find(irEDCdB - irEDCMaxLevel < -5, 1);
    if isempty(ir5dBSample), f = Inf; return; end
    ir35dBSample = find(irEDCdB - irEDCMaxLevel < -35, 1);
    if isempty(ir35dBSample), f = Inf; return; end
    irT60 = (ir35dBSample - ir5dBSample) * 2 / sampleRate;

    % EDT (early decay time, i.e. time from 0 to -10 dB)
    ir10dBSample = find(irEDCdB - irEDCMaxLevel < -10, 1);
    if isempty(ir10dBSample), f = Inf; return; end
    irEDT = (ir10dBSample - irMaxIndex) / sampleRate;

    % C80 (clarity)
    sample_80ms = floor(0.08 * sampleRate) + irMaxIndex;
    if sample_80ms >= numel(ir), f = Inf; return; end
    earlyEnergy = irEDC(irMaxIndex) - irEDC(sample_80ms);
    lateEnergy  = irEDC(sample_80ms);
    if lateEnergy <= 0, f = Inf; return; end
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    % BR (bass ratio)
    % Find amount of energy in 125 - 500Hz and 500Hz - 2000Hz bands and
    % calculate the ratio of the two
    irfft = abs(fft(ir));
    freq = (0:length(irfft)-1) * sampleRate / length(irfft);
    f125 = ceil(125 * length(irfft) / sampleRate) + 1;
    f500 = ceil(500 * length(irfft) / sampleRate);
    f2000 = floor(2000 * length(irfft) / sampleRate) + 1;
    lowContent = freq(f125:f500);
    highContent = freq((f500 + 1):f2000);
    lowEnergy = sum(lowContent .* lowContent);
    highEnergy = sum(highContent .* highContent);
    irBR = lowEnergy / highEnergy;
    
    %% Calculate fitness value
    % Calculate mean squared error
    loss.T60  = irT60  - params.T60;
    loss.ITDG = irITDG - params.ITDG;
    loss.EDT  = irEDT  - params.EDT;
    loss.C80  = irC80  - params.C80;
    loss.BR   = irBR   - params.BR;
    f = (loss.T60 * loss.T60) + ...
        (loss.ITDG * loss.ITDG) + ...
        (loss.EDT * loss.EDT) + ...
        (loss.C80 * loss.C80) + ...
        (loss.BR * loss.BR);
    f = f / 5;
end
