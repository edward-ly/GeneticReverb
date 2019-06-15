function f = fitness(ir, SAMPLE_RATE, ZERO_THRESHOLD, T60, ITDG, EDT, C80)
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response
% f = fitness value
    % Find highest sample and ignore previous samples for some descriptors.
    [impulseMaxAmplitude, impulseMaxSample] = max(ir(:, 1));
    impulseMaxDB = 20 * log10(abs(impulseMaxAmplitude));
    IR = ir((impulseMaxSample + 1):end, 1);

    % ITDG (initial time delay gap)
    irITDG = impulseMaxSample / SAMPLE_RATE;

    % T60
    impulseT60Sample = find( ...
        (IR > ZERO_THRESHOLD) & (20 * log10(IR) - impulseMaxDB < -60), 1 ...
    );
    if isempty(impulseT60Sample), impulseT60Sample = Inf; end
    irT60 = impulseT60Sample / SAMPLE_RATE;

    % EDT (early decay time, a.k.a. T10)
    impulseEdtSample = find( ...
        (IR > ZERO_THRESHOLD) & (20 * log10(IR) - impulseMaxDB < -10), 1 ...
    );
    if isempty(impulseEdtSample), impulseEdtSample = Inf; end
    irEDT = impulseEdtSample / SAMPLE_RATE;

    % C80 (clarity)
    sample_80ms = floor(0.08 * SAMPLE_RATE);
    earlyReflections = ir(1:sample_80ms, 1);
    lateReflections  = ir((sample_80ms + 1):end, 1);
    earlyEnergy = sum(earlyReflections .^ 2);
    lateEnergy  = sum(lateReflections  .^ 2);
    irC80 = 10 * log10(earlyEnergy / lateEnergy);

    f = (irT60  - T60 )^2 + ...
        (irITDG - ITDG)^2 + ...
        (irEDT  - EDT )^2 + ...
        (irC80  - C80 )^2;
end
