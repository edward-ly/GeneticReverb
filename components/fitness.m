function f = fitness(ir, SAMPLE_RATE, T60, ITDG, EDT, C80)
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response (column vector)
% f = fitness value
    % Calculate relative levels in decibels for each sample.
    irLevels = 20 .* log10(ir);

    % ITDG (initial time delay gap)
    % Calculate as time of highest intensity reflection.
    [irMaxLevel, irMaxIndex] = max(irLevels);
    irITDG = irMaxIndex / SAMPLE_RATE;

    % T60
    % Calculate time of first sample whose level is 60 dB below highest sample.
    irTestLevels = irLevels(irMaxIndex:end);
    irT60Sample = find(irTestLevels ~= -Inf & irTestLevels - irMaxLevel < -60, 1);
    if isempty(irT60Sample), f = Inf; return; end
    irT60 = irT60Sample / SAMPLE_RATE;

    % EDT (early decay time, a.k.a. T10)
    irT10Sample = find(irTestLevels ~= -Inf & irTestLevels - irMaxLevel < -10, 1);
    if isempty(irT10Sample), f = Inf; return; end
    irEDT = irT10Sample / SAMPLE_RATE;

    % C80 (clarity)
    sample_80ms = floor(0.08 * SAMPLE_RATE) + irMaxIndex;
    earlyReflections = ir(1:sample_80ms);
    lateReflections  = ir((sample_80ms + 1):end);
    earlyEnergy = sum(earlyReflections .* earlyReflections);
    lateEnergy  = sum(lateReflections .* lateReflections);
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    % Calculate the mean squared error.
    T60diff  = irT60  - T60;
    ITDGdiff = irITDG - ITDG;
    EDTdiff  = irEDT  - EDT;
    C80diff  = irC80  - C80;
    f = (T60diff * T60diff) + ...
        (ITDGdiff * ITDGdiff) + ...
        (EDTdiff * EDTdiff) + ...
        (C80diff * C80diff);
    f = f / 4;
end
