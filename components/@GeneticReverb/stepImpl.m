function out = stepImpl(plugin, in)
% STEPIMPL Main signal processing function for plugin
%
% Input arguments:
% plugin = plugin object
% in = input signal block
%
% Output arguments:
% out = output signal block
%
  % Calculate next convolution step for both channels
  if plugin.NUM_SAMPLES == 22500
    outL = step(plugin.pFIRFilterLeft22500, in(:, 1));
    outR = step(plugin.pFIRFilterRight22500, in(:, 2));
  elseif plugin.NUM_SAMPLES == 45000
    outL = step(plugin.pFIRFilterLeft45000, in(:, 1));
    outR = step(plugin.pFIRFilterRight45000, in(:, 2));
  elseif plugin.NUM_SAMPLES == 90000
    outL = step(plugin.pFIRFilterLeft90000, in(:, 1));
    outR = step(plugin.pFIRFilterRight90000, in(:, 2));
  elseif plugin.NUM_SAMPLES == 180000
    outL = step(plugin.pFIRFilterLeft180000, in(:, 1));
    outR = step(plugin.pFIRFilterRight180000, in(:, 2));
  elseif plugin.NUM_SAMPLES == 360000
    outL = step(plugin.pFIRFilterLeft360000, in(:, 1));
    outR = step(plugin.pFIRFilterRight360000, in(:, 2));
  elseif plugin.NUM_SAMPLES == 720000
    outL = step(plugin.pFIRFilterLeft720000, in(:, 1));
    outR = step(plugin.pFIRFilterRight720000, in(:, 2));
  elseif plugin.NUM_SAMPLES == 1440000
    outL = step(plugin.pFIRFilterLeft1440000, in(:, 1));
    outR = step(plugin.pFIRFilterRight1440000, in(:, 2));
  elseif plugin.NUM_SAMPLES == 2880000
    outL = step(plugin.pFIRFilterLeft2880000, in(:, 1));
    outR = step(plugin.pFIRFilterRight2880000, in(:, 2));
  else
    outL = in(:, 1);
    outR = in(:, 2);
  end
  out = [outL outR];

  % Apply gain to wet signal
  gain = 10 ^ (plugin.GAIN / 20);
  out = out .* gain;

  % Apply dry/wet mix
  out = in .* (1 - plugin.MIX / 100) + out .* plugin.MIX ./ 100;

  % Apply ILD via simple amplitude panning
  angle = atan(10 ^ (plugin.BALANCE / 20));
  gainL = sqrt(2) * cos(angle);
  gainR = sqrt(2) * sin(angle);
  out = bsxfun(@times, out, [gainL gainR]);
end
