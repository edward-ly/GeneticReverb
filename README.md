# Genetic Reverb

[![View Genetic Reverb - Genetic Algorithm-based VST Reverb Plugin on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/72437-genetic-reverb-genetic-algorithm-based-vst-reverb-plugin)

A VST 2 audio effect plugin written in MATLAB that uses a genetic algorithm to generate a random impulse response describing the reverberation of an artificial room, and uses the impulse response to apply convolution reverb to a signal in real-time. A MATLAB script version (`main.m`) is also available, which accepts a WAV audio file as input instead. The input is combined with the impulse response via convolution, applying the reverb effect to the pre-recorded audio.

Since no two impulse responses will ever be the same, both the script and the plugin are also able to save the generated impulse responses to new files as well. You can then load the generated impulse response files into other programs such as my simple [IR Reverb](https://github.com/edward-ly/reverb-pd) Pure Data patch or the [Convolution Reverb](https://www.ableton.com/en/packs/convolution-reverb/) device in [Ableton Live](https://www.ableton.com/en/) to perform the same reverb effect.

A video explaining and demonstrating (an older version of) the plugin is below:

[![Genetic Reverb](http://img.youtube.com/vi/Ef1d6nr7TqE/0.jpg)](http://www.youtube.com/watch?v=Ef1d6nr7TqE "Genetic Reverb")

This plugin was selected as a finalist in the [MATLAB Plugin Student Competition](http://www.aes.org/students/awards/mpsc/) at the [147th AES Convention in New York, 2019](http://www.aes.org/events/147/).

## Generating the Plugin

### Dependencies

- [MATLAB](https://www.mathworks.com/) (version R2018b or later)
  - Audio Toolbox
  - DSP System Toolbox
- (Windows) Microsoft Visual C++ 2017 (or higher)
- (Mac) Xcode 9.x (or higher)

First ensure that the `GeneticReverb.m` class file is visible to MATLAB by adding the `components` directory to the MATLAB path or directly changing to the `components` directory, running `addpath components` or `cd components`, respectively, in the MATLAB command window. Then validate the plugin with `validateAudioPlugin GeneticReverb` and generate the plugin with `generateAudioPlugin GeneticReverb`. You can then copy the `.dll` (Windows) or `.vst` (Mac) file into your DAW's VST plugins directory (or specify the directory when generating the plugin with `generateAudioPlugin -outdir <folder> GeneticReverb`).

> Note: Running `validateAudioPlugin GeneticReverb` will generate and save hundreds of binary files in the current directory as part of the validation. You can safely delete these files (or convert them to audio files and peruse them to your liking, see below).

## Running the Plugin

### Plugin Parameters

Listed below are the current user parameters of the plugin. You can change the impulse response parameters freely before generating the impulse responses using the "Generate Room" switch. Due to the spike in CPU usage that this can cause, you may experience a delay before the genetic algorithm is completed and the impulse response is able to be mixed with the input signal.

- Impulse Response Parameters
  - **Decay Time** - Specifies the amount of time it takes for the impulse response to decay 60 dB from the initial amplitude.
  - **Early Decay Time** - Specifies the amount of time it takes for the impulse response to decay 10 dB from the initial amplitude.
  - **Intimacy** - Specifies the amount of time between the arrival of the initial sound and the arrival of the next reflected sound. Higher intimacy values are typically associated with larger rooms.
  - **Clarity** - Specifies the difference in energy levels (in decibels) of early reflections compared to late reflections. Higher values increase the prominence of early reflections and thus increase the impulse response's rate of decay.
  - **Warmth** - Controls the low-frequency (125-500 Hz) to mid-frequency (500-2000 Hz) content ratio in the impulse response. A value of 50% represents a 1:1 ratio, and increasing or decreasing this value makes the impulse response more "warm" or "brilliant", respectively.
  - **Quality** - Adjusts the quality of the reverb by changing the amount of time given to the genetic algorithm to produce an impulse response (more specifically, changing the maximum number of generations allowed in the algorithm).
  - **Mono/Stereo** - Setting this to "mono" mode means that the genetic algorithm will generate only one impulse response to be used for both the left and right audio channels, while "stereo" mode makes the genetic algorithm generate two instead, one for each stereo channel to create a binaural effect.
  - **Normalize** - In "stereo" mode, turning this on will adjust the gain of one of the impulse responses so that both impulse responses have equal gain (according to average RMS amplitude). Otherwise, there may be some cases where one impulse response is much louder/quieter than the other.
- Post-Processing Parameters
  - **Dry/Wet** - Adjusts the balance between the dry input signal and the wet processed signal.
  - **Output Gain** - Adjusts the gain of the mixed dry/wet signal before being sent out the plugin.
- Special Parameters
  - **Generate Room** - Toggling the switch triggers the genetic algorithm in the plugin, using the current parameter values to generate new impulse responses.
  - **Toggle To Save** - Toggling the switch triggers the plugin to save the current impulse response as a binary (`.bin`) file in the same directory as the plugin. Useful if the plugin generates an impulse response you like and want to save it for later.

> Note 1: Make sure that the plugin is placed in a directory where it has write access; otherwise, no files will be generated at all.

> Note 2: Due to limitations with MATLAB code generation, the plugin is unable to save impulse responses directly as audio files at this time, but you can convert the binary files that the plugin creates to WAV files with the provided `bin2wav` or `bins2wav` MATLAB scripts.

## License

See [LICENSE](./LICENSE) for details.

## Last Updated

21 November 2019
