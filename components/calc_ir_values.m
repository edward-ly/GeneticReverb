function irValues = calc_ir_values(ir, numSamples, sampleRate)
% CALC_IR_VALUES Returns the acoustics parameter values of an impulse response.
%
% Input arguments:
% ir = column vector containing impulse response
% numSamples = length of impulse response
% sampleRate = sample rate of impulse response
%
% Output arguments:
% irValues = struct containing IR parameter values
%   T60 = T60 decay time (s)
%   EDT = early decay time (s)
%   PREDELAY = predelay time (s)
%   C80 = clarity (dB)
%   BR = bass ratio (dB)
%
  % Require all input arguments
  if nargin < 3, error('Not enough input arguments.'); end

  % =========================================================================

  % Find first reflection of impulse response
  [~, irInitSample] = max(abs(ir));

  % Calculate Schroeder curve of impulse response
  [irEDC, irEDCdB] = schroeder(ir);

  % =========================================================================

  % Predelay
  irDelay = irInitSample / sampleRate;

  % T60 & EDT
  % T60 = Calculate T30 (time from -5 to -35 dB) and multiply by 2
  % EDT = Calculate time from 0 to -10 dB
  ir5dBSample = find(irEDCdB < -5, 1);
  if isempty(ir5dBSample), ir5dBSample = -Inf; end

  ir10dBSample = find(irEDCdB < -10, 1);
  if isempty(ir10dBSample), ir10dBSample = Inf; end

  ir35dBSample = find(irEDCdB < -35, 1);
  if isempty(ir35dBSample), ir35dBSample = Inf; end

  irT60 = (ir35dBSample - ir5dBSample) * 2 / sampleRate;
  irEDT = (ir10dBSample - irInitSample) / sampleRate;

  % C80 (clarity)
  sample_80ms = round(0.08 * sampleRate);
  % if sample_80ms >= irParams.NUM_SAMPLES, f = Inf; return; end
  earlyEnergy = irEDC(1) - irEDC(sample_80ms);
  lateEnergy  = irEDC(sample_80ms);
  % lateEnergy(lateEnergy <= 0) = Inf;
  irC80 = 10 .* log10(earlyEnergy ./ lateEnergy);

  % BR (bass ratio)
  % Find amount of energy in 125 - 500Hz and 500Hz - 2000Hz bands and
  % calculate the ratio between the two
  irfft = 20 .* log10(abs(fft(ir)));
  f125 = ceil(125 * numSamples / sampleRate) + 1;
  f500 = ceil(500 * numSamples / sampleRate);
  f2000 = floor(2000 * numSamples / sampleRate) + 1;
  lowContent = mean(irfft(f125:f500));
  highContent = mean(irfft((f500 + 1):f2000));
  irBR = lowContent - highContent;

  irValues = struct( ...
    'PREDELAY', irDelay, ...
    'T60', irT60, ...
    'EDT', irEDT, ...
    'C80', irC80, ...
    'BR', irBR);
end
