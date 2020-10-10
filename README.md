# Genetic Reverb

[![View Genetic Reverb - Genetic Algorithm-based VST Reverb Plugin on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/72437-genetic-reverb-genetic-algorithm-based-vst-reverb-plugin)

A VST 2 audio effect plugin written in MATLAB that uses a genetic algorithm to generate a random impulse response describing the reverberation of an artificial room, and uses the impulse response to apply convolution reverb to an audio signal in real-time.
A MATLAB script version (`main.m`) is also available, which accepts a WAV audio file as input instead.
The input is combined with the impulse response via convolution, applying the reverb effect to the pre-recorded audio.

Since no two impulse responses will ever be the same, both the script and the plugin are also able to save the generated impulse responses to new files as well.
You can then load the generated impulse response files into other programs such as my simple [IR Reverb](https://github.com/edward-ly/reverb-pd) Pure Data patch or the [Convolution Reverb](https://www.ableton.com/en/packs/convolution-reverb/) device in [Ableton Live](https://www.ableton.com/en/) to perform the same reverb effect.

This plugin was selected as a finalist in the [MATLAB Plugin Student Competition](http://www.aes.org/students/awards/mpsc/) at the [147th AES Convention in New York, 2019](http://www.aes.org/events/147/).

### Demo

A video explaining and demonstrating (an older version of) the plugin is below:

[![Genetic Reverb](http://img.youtube.com/vi/Ef1d6nr7TqE/0.jpg)](http://www.youtube.com/watch?v=Ef1d6nr7TqE "Genetic Reverb")

I also used the plugin to create an entire demo track, which you can listen to and download here: [https://soundcloud.com/9646/inner-space](https://soundcloud.com/9646/inner-space).

## Installing the Plugin

You can start using the plugin right away (without the need to compile from source code) by extracting the contents of the provided `.zip` file and then copying the desired file(s) into the plugins directory specified by your VST host application.
The included plugins, however, do not have the ability to save the generated impulse responses at this time.

#### Included Files

The plugin is available in the following formats:

- Windows
  - `GeneticReverb_x86.dll` (32-bit VST Plugin)
  - `GeneticReverb_x64.dll` (64-bit VST Plugin)
  - `GeneticReverb.exe` (Standalone Executable)
- macOS
  - `GeneticReverb.vst` (VST Plugin)
  - `GeneticReverb.component` (AU Plugin)
  - `GeneticReverb.app` (Standalone Executable)

## Generating the Plugin

### Dependencies

- [MATLAB](https://www.mathworks.com/) (version R2020a or later)
  - Audio Toolbox
  - DSP System Toolbox
  - Signal Processing Toolbox
  - Statistics and Machine Learning Toolbox
- (Windows) Microsoft Visual C++ 2017 (or higher)
- (macOS) Xcode 9.x (or higher)

First ensure that the `GeneticReverb.m` class file is visible to MATLAB by adding the `components` directory to the MATLAB path or directly changing to the `components` directory, running `addpath components` or `cd components`, respectively, in the MATLAB command window.
Then validate the plugin with `validateAudioPlugin GeneticReverb` and generate the plugin with `generateAudioPlugin GeneticReverb`.
You can also specify the output directory when generating the plugin with `generateAudioPlugin -outdir path/to/folder/ GeneticReverb`.

> Note 1: Running `validateAudioPlugin GeneticReverb` will generate and save hundreds of binary files in the current directory as part of the validation.
You can safely delete these files (or convert them to audio files and peruse them to your liking, see note 2).

## Running the Plugin

### Plugin Parameters

Listed below are the current user parameters of the plugin.
You can change the impulse response parameters freely before generating the impulse responses using the "Generate Room" switch.
Due to the spike in CPU usage that this can cause, you may experience a delay before the genetic algorithm is completed and the impulse response(s) can be convolved with the input signal.
Adding automation to any of the parameters (other than "Dry/Wet" and "Output Gain") is also not recommended for this reason.

- Impulse Response Parameters
  - **Decay Time** - Specifies the amount of time it takes for the impulse response to decay 60 dB from the initial amplitude.
  - **Early Decay Time** - Specifies the amount of time it takes for the impulse response to decay 10 dB from the initial amplitude, expressed as a percentage of the total decay time.
  - **Clarity** - Specifies the difference in energy levels (in decibels) of early reflections compared to late reflections.
      Higher values increase the prominence of early reflections and thus increase the impulse response's rate of decay.
  - **Warmth** - Specifies the difference in energy levels (in decibels) of low-frequency (125-500 Hz) content compared to mid-frequency (500-2000 Hz) content.
      A value of 0 dB represents a 1:1 ratio (flat response), and increasing or decreasing this value makes the impulse response more "warm" or "brilliant", respectively.
  - **Predelay** - Specifies the amount of time delay before the arrival of the direct sound in the impulse response.
      Higher values also contribute to the impression of larger rooms.
      Currently available as two separate knobs in the plugin, one for each of the left and right stereo channels to delay each impulse response separately.
  - **Mono/Stereo** - Setting this to "mono" mode means that the genetic algorithm will generate only one impulse response to be used for both the left and right audio channels, while "stereo" mode makes the genetic algorithm generate two instead, one for each stereo channel to create a binaural effect.
  - **Normalize** - If set to "On", adjusts the gain of the two impulse responses so that their RMS levels are equal.
      Otherwise, the difference in RMS levels will only be limited by the maximum possible ILD (Interaural Level Difference, assumed to be 20 dB in the plugin).
      Works in "stereo" mode only.
  - **Quality** - Specifies the quality of the reverb by changing the amount of time given to the genetic algorithm to produce an impulse response (more specifically, changing various parameters in the genetic algorithm such as the population size or the maximum number of generations to execute).
- Post-Processing Parameters
  - **Output Gain** - Adjusts the gain of the wet signal before being mixed with the dry input signal.
  - **Dry/Wet** - Adjusts the balance between the dry input signal and the wet processed signal.
- Special Parameters
  - **Generate Room** - Toggling the switch triggers the genetic algorithm in the plugin, using the current parameter values to generate new impulse responses.
  - **Toggle To Save** - Toggling the switch triggers the plugin to save the current impulse response as a binary (`.bin`) file in the same directory as the plugin.
      Useful if the plugin generates an impulse response you like and want to save it for later.

> Note 2: Due to limitations with MATLAB code generation, the plugin is unable to save impulse responses directly as audio files at this time, but you can convert the binary files that the plugin creates to WAV files with the provided `bin2wav` or `bins2wav` MATLAB scripts.
In addition, saving will not work unless you specify the full path to the desired directory via the `SAVE_IR_PATH` property value in `components/@GeneticReverb/GeneticReverb.m`.
Make sure that the plugin has write access to the specified directory as well.

## License

See [LICENSE](./LICENSE) for details.

## Last Updated

10 October 2020
