function f = fitness(ir, SAMPLE_RATE, T60, ITDG, EDT, C80)
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response (column vector)
% f = fitness value
    % Calculate intensity values for each sample.
    irIntensities = ir .^ 2;

    % Find peaks in intensity for remaining fitness calculations.
    MIN_PEAK_TIME = 0.001;
    MIN_INTENSITY_LEVEL = 1e-3;
    maxIntensity = max(irIntensities);
    [peakIntensities, peakTimes] = findpeaks( ...
        irIntensities, ...
        SAMPLE_RATE, ...
        "MinPeakDistance", MIN_PEAK_TIME, ...
        "MinPeakProminence", maxIntensity * MIN_INTENSITY_LEVEL, ...
        "MinPeakHeight", maxIntensity * MIN_INTENSITY_LEVEL ...
    );
    if isempty(peakIntensities), f = Inf; return; end

    % Find sample of highest intensity and calculate its dB level.
    [irMaxIntensity, irMaxTimeIndex] = max(peakIntensities);
    irMaxDB = 10 * log10(irMaxIntensity);

    % ITDG (initial time delay gap)
    irITDG = peakTimes(irMaxTimeIndex);

    % T60
    % Calculate as T30 * 2, where T30 is approximately the time of last peak
    % above -30 dB minus time of peak at 0 dB.
    irT60 = 2 * (peakTimes(end) - irITDG);

    % EDT (early decay time, a.k.a. T10)
    peakLevels = 10 .* log10(peakIntensities) - irMaxDB;
    irEdtPeakTimeIndices = peakLevels < -10;
    irEdtPeakTimes = peakTimes(irEdtPeakTimeIndices);
    irEDT = min(irEdtPeakTimes(irEdtPeakTimes > irITDG));
    if isempty(irEDT), f = Inf; return; end

    % C80 (clarity)
    sample_80ms = floor(0.08 * SAMPLE_RATE);
    earlyReflections = irIntensities(1:sample_80ms);
    lateReflections  = irIntensities((sample_80ms + 1):end);
    earlyEnergy = sum(earlyReflections);
    lateEnergy  = sum(lateReflections);
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    % Calculate RMS error value.
    f = (irT60  - T60) ^ 2 + ...
        (irITDG - ITDG) ^ 2 + ...
        (irEDT  - EDT) ^ 2 + ...
        (irC80  - C80) ^ 2;
end
