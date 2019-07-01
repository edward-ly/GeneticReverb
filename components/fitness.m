function f = fitness(ir, SAMPLE_RATE, T60, ITDG, EDT, C80)
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response (column vector)
% f = fitness value
    % Calculate relative levels in decibels for each sample.
    irLevels = 10 .* log10(ir .^ 2);

    % ITDG (initial time delay gap)
    % Calculate time of highest intensity.
    [~, irMaxIndex] = max(irLevels);
    irITDG = irMaxIndex / SAMPLE_RATE;

    % T60
    % Calculate slope in dB/s of linear regression of impulse response levels,
    % then divide -60 dB by the slope to get T60.
    % Ignore first 0.1 seconds for better results.
    sample_100ms = ceil(0.1 * SAMPLE_RATE);
    x = (sample_100ms:length(irLevels))' ./ SAMPLE_RATE;
    X = [ones(length(x), 1) x];
    Y = irLevels(sample_100ms:end);
    linReg = X \ Y;
    irT60 = -60 / linReg(2);

    % EDT (early decay time, a.k.a. T10)
    irEDT = irT60 / 6;

    % C80 (clarity)
    sample_80ms = floor(0.08 * SAMPLE_RATE);
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
