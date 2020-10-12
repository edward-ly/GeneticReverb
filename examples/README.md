# Genetic Reverb (Example Audio)

This folder contains various example audio files and impulse responses to demonstrate the genetic algorithm.
Includes anechoic audio along with real, recorded impulse responses from the [OpenAIR Database](https://openairlib.net/) for reference.

Sources (from [OpenAIR Database](https://openairlib.net/) unless otherwise specified):
- `dry/`
  - `drums.wav`: "Anechoic drums" audio example
  - `speech.wav`: [Intelligibility-enhancing speech modifications: the Hurricane Challenge](http://www.cstr.ed.ac.uk/downloads/publications/2013/Cooke_IS13.pdf)
- `irs/`
  - `ir_arthur_s1r4_ch1.wav`: Arthur Sykes Rymer Auditorium, University of York - Source Position 1, Receiver Position 4, Channel 1
  - `ir_council_s1r1_ch1.wav`: York Guildhall Council Chamber - Source Position 1, Receiver Position 1, Channel 1
  - `ir_jack_lp4_ch1.wav`: Jack Lyons Concert Hall, University of York - Listening Position 4, Channel 1

The decay time, early decay time, clarity, and warmth values for each impulse response were calculated via the same algorithms used in the fitness function of the genetic algorithm, and new impulse responses were generated on "High" and "Max" settings using these same values.

| Base Impulse Response | Quality | Output File |
| --- | --- | --- |
| `ir_arthur_s1r4_ch1.wav`  | High | `ir_arthur_s1r4_ch1_ga_high.wav` |
| `ir_arthur_s1r4_ch1.wav`  | Max  | `ir_arthur_s1r4_ch1_ga_max.wav`  |
| `ir_council_s1r1_ch1.wav` | High | `ir_council_s1r1_ch1_ga_high.wav` |
| `ir_council_s1r1_ch1.wav` | Max  | `ir_council_s1r1_ch1_ga_max.wav` |
| `ir_jack_lp4_ch1.wav`     | High | `ir_jack_lp4_ch1_ga_high.wav` |
| `ir_jack_lp4_ch1.wav`     | Max  | `ir_jack_lp4_ch1_ga_max.wav` |

The reverberated (wet) audio as a result of convolution with the dry audio and the impulse responses are also included so that you can hear the differences between the impulse responses (or lack thereof) for yourself.

| Dry Audio | Impulse Response | Output File |
| --- | --- | --- |
| `drums.wav`  | `ir_arthur_s1r4_ch1.wav` | `drums_arthur_s1r4_ch1.wav` |
| `drums.wav`  | `ir_arthur_s1r4_ch1_ga_high.wav` | `drums_arthur_s1r4_ch1_ga_high.wav` |
| `drums.wav`  | `ir_arthur_s1r4_ch1_ga_max.wav` | `drums_arthur_s1r4_ch1_ga_max.wav` |
| `drums.wav`  | `ir_council_s1r1_ch1.wav` | `drums_council_s1r1_ch1.wav` |
| `drums.wav`  | `ir_council_s1r1_ch1_ga_high.wav` | `drums_council_s1r1_ch1_ga_high.wav` |
| `drums.wav`  | `ir_council_s1r1_ch1_ga_max.wav` | `drums_council_s1r1_ch1_ga_max.wav` |
| `drums.wav`  | `ir_jack_lp4_ch1.wav` | `drums_jack_lp4_ch1.wav` |
| `drums.wav`  | `ir_jack_lp4_ch1_ga_high.wav` | `drums_jack_lp4_ch1_ga_high.wav` |
| `drums.wav`  | `ir_jack_lp4_ch1_ga_max.wav` | `drums_jack_lp4_ch1_ga_max.wav` |
| `speech.wav`  | `ir_arthur_s1r4_ch1.wav` | `speech_arthur_s1r4_ch1.wav` |
| `speech.wav`  | `ir_arthur_s1r4_ch1_ga_high.wav` | `speech_arthur_s1r4_ch1_ga_high.wav` |
| `speech.wav`  | `ir_arthur_s1r4_ch1_ga_max.wav` | `speech_arthur_s1r4_ch1_ga_max.wav` |
| `speech.wav`  | `ir_council_s1r1_ch1.wav` | `speech_council_s1r1_ch1.wav` |
| `speech.wav`  | `ir_council_s1r1_ch1_ga_high.wav` | `speech_council_s1r1_ch1_ga_high.wav` |
| `speech.wav`  | `ir_council_s1r1_ch1_ga_max.wav` | `speech_council_s1r1_ch1_ga_max.wav` |
| `speech.wav`  | `ir_jack_lp4_ch1.wav` | `speech_jack_lp4_ch1.wav` |
| `speech.wav`  | `ir_jack_lp4_ch1_ga_high.wav` | `speech_jack_lp4_ch1_ga_high.wav` |
| `speech.wav`  | `ir_jack_lp4_ch1_ga_max.wav` | `speech_jack_lp4_ch1_ga_max.wav` |

## Last Updated

12 October 2020
