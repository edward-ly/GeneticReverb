function [f, loss, outDev] = fitness(irPop, params, popSize, inDev)
% FITNESS Calculate fitness values of all impulse responses in population.
%
% Input arguments:
% irPop = column matrix containing impulse response population
% params = struct containing impulse response parameters
%     SAMPLE_RATE = sample rate of impulse response
%     NUM_SAMPLES = length of recorded impulse response (samples)
%     T60 = T60 decay time (s)
%     EDT = early decay time (s)
%     C80 = clarity (dB)
%     BR = bass ratio
% popSize = number of impulse responses in the population
% inDev = standard deviation of initial population for each parameter
%
% Output arguments:
% f = row vector containing fitness values of impulse response population
% loss = struct containing error/difference values for each parameter (optional)
% outDev = standard deviation of initial population for each parameter
%
    % Require all input arguments and fitness value output
    if nargin < 4, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    % =========================================================================

    % Initialize loss output
    loss = struct( ...
        'T60', zeros(1, popSize), ...
        'EDT', zeros(1, popSize), ...
        'C80', zeros(1, popSize), ...
        'BR', zeros(1, popSize));

    % Copy sample rate to new variable (to shorten name)
    sampleRate = params.SAMPLE_RATE;
    numSamples = params.NUM_SAMPLES;

    % Calculate Schroeder curve of impulse responses
    [irEDC, irEDCdB] = schroeder(irPop);

    % =========================================================================

    % T60 & EDT
    % T60 = Calculate T30 (time from -5 to -35 dB) and multiply by 2
    % EDT = Calculate time from 0 to -10 dB
    irEDCMaxLevel = irEDCdB(1, :);
    ir5dBSamples = zeros(1, popSize);
    ir10dBSamples = zeros(1, popSize);
    ir35dBSamples = zeros(1, popSize);

    for i = 1:popSize
        ir5dBSample = find(irEDCdB(:, i) - irEDCMaxLevel(i) < -5, 1);
        if isempty(ir5dBSample)
            ir5dBSamples(i) = -Inf;
        else
            ir5dBSamples(i) = ir5dBSample;
        end

        ir10dBSample = find(irEDCdB(:, i) - irEDCMaxLevel(i) < -10, 1);
        if isempty(ir10dBSample)
            ir10dBSamples(i) = Inf;
        else
            ir10dBSamples(i) = ir10dBSample;
        end

        ir35dBSample = find(irEDCdB(:, i) - irEDCMaxLevel(i) < -35, 1);
        if isempty(ir35dBSample)
            ir35dBSamples(i) = Inf;
        else
            ir35dBSamples(i) = ir35dBSample;
        end
    end

    irT60 = (ir35dBSamples - ir5dBSamples) .* 2 ./ sampleRate;
    irEDT = (ir10dBSamples - 1) ./ sampleRate;

    % C80 (clarity)
    sample_80ms = round(0.08 * sampleRate) + 1;
    % if sample_80ms >= irParams.NUM_SAMPLES, f = Inf; return; end
    earlyEnergy = irEDC(1, :) - irEDC(sample_80ms, :);
    lateEnergy  = irEDC(sample_80ms, :);
    % lateEnergy(lateEnergy <= 0) = Inf;
    irC80 = 10 .* log10(earlyEnergy ./ lateEnergy);

    % BR (bass ratio)
    % Find amount of energy in 125 - 500Hz and 500Hz - 2000Hz bands and
    % calculate the ratio between the two
    irfft = abs(fft(irPop));
    f125 = ceil(125 * numSamples / sampleRate) + 1;
    f500 = ceil(500 * numSamples / sampleRate);
    f2000 = floor(2000 * numSamples / sampleRate) + 1;
    lowContent = irfft(f125:f500, :);
    highContent = irfft((f500 + 1):f2000, :);
    lowEnergy = sum(lowContent .* lowContent);
    highEnergy = sum(highContent .* highContent);
    % Divide highEnergy by 4 to compensate for the fact that the highFrequency
    % bin is 4 times as wide
    highEnergy = highEnergy ./ 4;
    irBR = lowEnergy ./ highEnergy;
    
    % =========================================================================

    % Calculate std of initial population only
    outDev = inDev;
    if outDev.T60 == 0, outDev.T60 = std(irT60); end
    if outDev.EDT == 0, outDev.EDT = std(irEDT); end
    if outDev.C80 == 0, outDev.C80 = std(irC80); end
    if outDev.BR == 0, outDev.BR = std(irBR); end

    % Calculate fitness value
    % Convert all values to z-scores with means equal to plugin parameter
    % values, then add magnitudes of z-scores together
    loss.T60  = (irT60 - params.T60) ./ outDev.T60;
    loss.EDT  = (irEDT - params.EDT) ./ outDev.EDT;
    loss.C80  = (irC80 - params.C80) ./ outDev.C80;
    loss.BR   = (irBR - params.BR) ./ outDev.BR;
    f = abs(loss.T60) + abs(loss.EDT) + abs(loss.C80) + abs(loss.BR);
end
