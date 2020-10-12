function resetImpl(plugin)
% RESETIMPL Reset DSP system objects in plugin
% Requires plugin object as input argument
%
  reset(plugin.pFIRFilterLeft22500);
  reset(plugin.pFIRFilterLeft45000);
  reset(plugin.pFIRFilterLeft90000);
  reset(plugin.pFIRFilterLeft180000);
  reset(plugin.pFIRFilterLeft360000);
  reset(plugin.pFIRFilterLeft720000);
  reset(plugin.pFIRFilterLeft1440000);
  reset(plugin.pFIRFilterLeft2880000);

  reset(plugin.pFIRFilterRight22500);
  reset(plugin.pFIRFilterRight45000);
  reset(plugin.pFIRFilterRight90000);
  reset(plugin.pFIRFilterRight180000);
  reset(plugin.pFIRFilterRight360000);
  reset(plugin.pFIRFilterRight720000);
  reset(plugin.pFIRFilterRight1440000);
  reset(plugin.pFIRFilterRight2880000);

  reset(plugin.pFIR22050);
  reset(plugin.pFIR32000);
  reset(plugin.pFIR44100);
  reset(plugin.pFIR48000);
  reset(plugin.pFIR88200);
  reset(plugin.pFIR96000);
  reset(plugin.pFIR192000);
end
