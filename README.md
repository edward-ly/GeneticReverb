# Genetic Reverb

A VST 2 audio plugin written in MATLAB that uses a genetic algorithm to generate a random impulse response describing the reverberation of an artificial room, and uses the impulse response to apply reverb to a signal in real-time. A script version (`main.m`) is also available, which accepts a WAV audio file as input to combine with the impulse response via convolution to allow for hearing the reverb effect on pre-recorded audio.

You can also load the generated impulse response WAV file to perform the same reverb effect in other programs such as my simple [IR Reverb](https://github.com/edward-ly/reverb-pd) Pure Data patch or the [Convolution Reverb](https://www.ableton.com/en/packs/convolution-reverb/) device in [Ableton Live](https://www.ableton.com/en/).

## Generating and Running the Plugin

In the MATLAB command window under the `components` directory, first validate the plugin with `validateAudioPlugin GeneticReverb` (warning: this process can take around an hour or more to complete), then generate the plugin with `generateAudioPlugin GeneticReverb`. You can then copy the `.dll` (Windows) or `.vst` (Mac) file into your VST plugins folder or add the project directory to your DAW's plugin file path.

## Running the Script

Open the `main.m` script in the MATLAB editor and adjust parameter values as needed. Then you can click on __Editor > Run__ or run `main` in the MATLAB command window under the project root directory.

## License

See [LICENSE](./LICENSE) for details.

## Last Updated

6 August 2019
