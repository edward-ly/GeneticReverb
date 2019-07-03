function f = fitness(ir, SAMPLE_RATE, T60, ITDG, EDT, C80)
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response (column vector)
% f = fitness value
    % Calculate relative levels in decibels for each sample.
    irLevels = 10 .* log10(ir .^ 2);

    % ITDG (initial time delay gap)
    % Calculate as time of highest intensity reflection.
    [irMaxLevel, irMaxIndex] = max(irLevels);
    irITDG = irMaxIndex / SAMPLE_RATE;

    % T60
    % Calculate first time at which sample level is 60 dB below highest sample.
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
    earlyEnergy = sum(earlyReflections .^ 2);
    lateEnergy  = sum(lateReflections .^ 2);
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    % Calculate the mean squared error.
    f = (irT60  - T60) ^ 2 + ...
        (irITDG - ITDG) ^ 2 + ...
        (irEDT  - EDT) ^ 2 + ...
        (irC80  - C80) ^ 2;
    f = f / 4;
end
