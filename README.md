# Genetic Reverb

A MATLAB script that uses a genetic algorithm to generate an impulse response describing the reverberation of an artificial room. It also accepts a WAV audio file as input to allow for hearing the reverb effect on an audio source.

You can also load the generated impulse response into the [IR Reverb](https://github.com/edward-ly/reverb-pd) Pure Data patch to perform the reverb effect in real-time.

## Dependencies

* [RIR Generator](https://www.audiolabs-erlangen.de/fau/professor/habets/software/rir-generator) (Habets, 2014)

## Setup

In the project root directory, clone the RIR Generator repository into a new directory (we recommend something like `packages/RIR-Generator/`).

```sh
>> git clone git@github.com:ehabets/RIR-Generator.git packages/RIR-Generator/
```

Now you can compile the source code for the `rir_generator` MEX function from the MATLAB command window.

```sh
>> mex -setup C++
>> mex path/to/rir_generator.cpp
```

Now the binary MEX file should be added to the project root directory.

## Running the Script

To run the script, open `main.m` in the MATLAB editor, adjust parameter values as needed, and click on __Editor > Run__ or run `main` in the MATLAB command window.

## License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

RIR Generator (c) 2003-2010 E.A.P. Habets, The Netherlands.

## Last Updated

18 June 2019
