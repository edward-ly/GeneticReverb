function f = fitness(ir, SAMPLE_RATE, T60, ITDG, EDT, C80, BR)
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response (column vector)
% f = fitness value
    % Require all arguments
    if nargin < 7, error('Not enough input arguments.'); end

    % Calculate relative levels in decibels for each sample.
    irLevels = 20 .* log10(ir);
    [irMaxLevel, irMaxIndex] = max(irLevels);

    % ITDG (initial time delay gap)
    % Calculate time difference between first two arrivals.
    irIndices = find(ir, 2);
    if numel(irIndices) < 2, f = Inf; return; end
    irITDG = (irIndices(2) - irIndices(1)) / SAMPLE_RATE;

    % T60
    % Calculate time of first sample whose level is 60 dB below highest sample.
    irTestLevels = irLevels(irMaxIndex:end);
    irT60Sample = find( ...
        irTestLevels ~= -Inf & irTestLevels - irMaxLevel < -60, 1);
    if isempty(irT60Sample), f = Inf; return; end
    irT60 = irT60Sample / SAMPLE_RATE;

    % EDT (early decay time, a.k.a. T10)
    irT10Sample = find( ...
        irTestLevels ~= -Inf & irTestLevels - irMaxLevel < -10, 1);
    if isempty(irT10Sample), f = Inf; return; end
    irEDT = irT10Sample / SAMPLE_RATE;

    % C80 (clarity)
    sample_80ms = floor(0.08 * SAMPLE_RATE) + irMaxIndex;
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
