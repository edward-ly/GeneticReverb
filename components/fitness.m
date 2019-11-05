function f = fitness(ir, SAMPLE_RATE, T60, ITDG, EDT, C80, BR)
% FITNESS Calculate fitness value of impulse response.
%
% Input arguments:
% ir = column vector containing impulse response
% SAMPLE_RATE = sample rate of impulse response
% T60 = T60 decay time (s)
% ITDG = initial time delay gap (s)
% EDT = early decay time (s)
% C80 = clarity (dB)
% BR = bass ratio
%
% Output arguments:
% f = fitness value
%
    % Require all arguments
    if nargin < 7, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % Get start time of IR (arrival of peak reflection).
    [~, irMaxIndex] = max(abs(ir));

    % ITDG (initial time delay gap)
    % Calculate time difference between first two arrivals.
    irIndices = find(ir, 2);
    if numel(irIndices) < 2, f = Inf; return; end
    irITDG = (irIndices(2) - irIndices(1)) / SAMPLE_RATE;

    % T60
    % Calculate T30 (time from -5 to -35 dB) and multiply by 2.
    irEDC = schroeder(ir, 'dB');
    irEDCMaxLevel = irEDC(irMaxIndex);
    ir5dBSample = find(irEDC - irEDCMaxLevel < -5, 1);
    if isempty(ir5dBSample), f = Inf; return; end
    ir35dBSample = find(irEDC - irEDCMaxLevel < -35, 1);
    if isempty(ir35dBSample), f = Inf; return; end
    irT60 = (ir35dBSample - ir5dBSample) * 2 / SAMPLE_RATE;

    % EDT (early decay time, i.e. time from 0 to -10 dB)
    ir10dBSample = find(irEDC - irEDCMaxLevel < -10, 1);
    if isempty(ir10dBSample), f = Inf; return; end
    irEDT = (ir10dBSample - irMaxIndex) / SAMPLE_RATE;

    % C80 (clarity)
    sample_80ms = floor(0.08 * SAMPLE_RATE) + irMaxIndex;
    if sample_80ms >= numel(ir), f = Inf; return; end
    earlyReflections = ir(1:sample_80ms);
    lateReflections  = ir((sample_80ms + 1):end);
    earlyEnergy = sum(earlyReflections .* earlyReflections);
    lateEnergy  = sum(lateReflections .* lateReflections);
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    % BR (bass ratio)
    % Find amount of energy in 125 - 500Hz and 500Hz - 2000Hz bands and
    % calculate the ratio of the two.
    irfft = abs(fft(ir));
    freq = (0:length(irfft)-1) * SAMPLE_RATE / length(irfft);
    f125 = ceil(125 * length(irfft) / SAMPLE_RATE) + 1;
    f500 = ceil(500 * length(irfft) / SAMPLE_RATE);
    f2000 = floor(2000 * length(irfft) / SAMPLE_RATE) + 1;
    lowContent = freq(f125:f500);
    highContent = freq((f500 + 1):f2000);
    lowEnergy = sum(lowContent .* lowContent);
    highEnergy = sum(highContent .* highContent);
    irBR = lowEnergy / highEnergy;
    
    % Calculate the mean squared error.
    T60diff  = irT60  - T60;
    ITDGdiff = irITDG - ITDG;
    EDTdiff  = irEDT  - EDT;
    C80diff  = irC80  - C80;
    BRdiff   = irBR   - BR;
    f = (T60diff * T60diff) + ...
        (ITDGdiff * ITDGdiff) + ...
        (EDTdiff * EDTdiff) + ...
        (C80diff * C80diff) + ...
        (BRdiff * BRdiff);
    f = f / 5;
end
