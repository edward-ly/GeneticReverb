/*
Program     : Fast Room Impulse Response Generator

Description : Calculates the impulse response of a box-shaped room using the
              fast image method [1].
              For test purposes only.

              [1] Stephen G. McGovern,
              Fast image method for impulse response calculations of box-shaped
              rooms, Applied Acoustics 70 (2009), 182-189.

Author      : Edward Ly (m5222120@u-aizu.ac.jp)
Version     : 0.1.0
*/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// Data structure to hold data for a particular dimension
struct axisVar {
  double w;        // room width
  double r;        // distance from receiver to origin
  double s;        // distance from sound source to origin
  double Bmw;      // reflection coefficient of wall to left of origin
  double Bw;       // reflection coefficient of wall to right of origin
  int n;           // highest order reflection for lookup tables
  double* distSq;  // pointer to square-of-distance lookup table
  double* refCoef; // pointer to reflection coefficient lookup table
};

//-----------------------------------------------------------------------------

// Create square-of-distance and reflection coefficient lookup tables
void makeTables (struct axisVar a) {
  double Limg = 1, Rimg = 1, DirSnd;
  double RimgD, LimgD;

  // Set 1st value of reflection coefficient table
  a.refCoef[0] = 1;

  // Set 1st value of square-of-distance table
  DirSnd = a.s - a.r;
  a.distSq[0] = DirSnd * DirSnd;

  // Set initial values of left/right image distance sequences
  LimgD = DirSnd;
  RimgD = DirSnd;

  // Create tables
  for (int i = 1; i <= a.n; i++) {
    // Set image distances and reflection coefficients for i^th order images on
    // left and right
    if (i % 2 != 0) {
      LimgD -= 2 * (a.w + a.s);
      RimgD += 2 * (a.w - a.s);
      Limg  *= a.Bmw;
      Rimg  *= a.Bw;
    } else {
      LimgD -= 2 * (a.w - a.s);
      RimgD += 2 * (a.w + a.s);
      Limg  *= a.Bw;
      Rimg  *= a.Bmw;
    }

    // Determine pattern for i^th order echo pair and set values for both tables
    if ((i % 2 != 0 && a.r + a.s < 0) || (i % 2 == 0 && a.r - a.s < 0)) {
      a.distSq [2*i - 1] = LimgD * LimgD;
      a.distSq [2*i    ] = RimgD * RimgD;
      a.refCoef[2*i - 1] = Limg;
      a.refCoef[2*i    ] = Rimg;
    } else {
      a.distSq [2*i - 1] = RimgD * RimgD;
      a.distSq [2*i    ] = LimgD * LimgD;
      a.refCoef[2*i - 1] = Rimg;
      a.refCoef[2*i    ] = Limg;
    }
  }
}

//-----------------------------------------------------------------------------

// main function
int main () {
  double c, time, *h, dist;
  int length, sampleRate, samp;
  int i, j, k;

  // Declare 3 structs to hold info for each dimension
  struct axisVar x, y, z;

  // Set speed of sound, total time, and sample rate
  c = 343.0;
  time = 1.5;
  sampleRate = 44100;

  // Calculate length of impulse response in number of samples
  length = (int)((double)sampleRate * time);

  // Set room dimensions (width), source position, receiver position
  x.w = 5; y.w = 5; z.w = 4.5;
  x.r = 4; y.r = 2; z.r = 2;
  x.s = 1; y.s = 1; z.s = 0.5;

  // Set reflection coefficients for each wall
  x.Bmw = 0.7; x.Bw = 0.7;
  y.Bmw = 0.7; y.Bw = 0.7;
  z.Bmw = 0.7; z.Bw = 0.7;

  // Find highest-order reflection to be used in lookup tables
  x.n = (int)ceil(c * time / (2 * x.w));
  y.n = (int)ceil(c * time / (2 * y.w));
  z.n = (int)ceil(c * time / (2 * z.w));

  // Initialize lookup tables
  x.distSq  = (double*)malloc((2*x.n + 1) * sizeof(double));
  y.distSq  = (double*)malloc((2*y.n + 1) * sizeof(double));
  z.distSq  = (double*)malloc((2*z.n + 1) * sizeof(double));
  x.refCoef = (double*)malloc((2*x.n + 1) * sizeof(double));
  y.refCoef = (double*)malloc((2*y.n + 1) * sizeof(double));
  z.refCoef = (double*)malloc((2*z.n + 1) * sizeof(double));

  // Create tables for each dimension
  makeTables(x);
  makeTables(y);
  makeTables(z);

  // Initialize impulse response array
  h = (double*)calloc(length, 8);

  // Use lookup tables to calculate impulse response
  for (i = 0; i < 2*x.n + 1; i++) {
    for (j = 0; j < 2*y.n + 1; j++) {
      for (k = 0; k < 2*z.n + 1; k++) {
        // Find distance from ijk^th image to receiver
        dist = sqrt(x.distSq[i] + y.distSq[j] + z.distSq[k]);

        // Find sample in impulse response corresponding to distance
        samp = (int)(dist * (double)(sampleRate) / c + 0.5);

        // If echo from ijk^th image occurs at a time beyond range of impulse
        // response, then all images in one strip of circle have been tested.
        if (samp >= length) break;

        // Add echo to impulse response array
        h[samp] += x.refCoef[i] * y.refCoef[j] * z.refCoef[k] / dist;
      }

      // If k-loop broke with k == 0, then all images in "circle of interest"
      // in i-plane have been tested, so no need to find distances for higher
      // values of j.
      if (k == 0) break;
    }

    // If j-loop broke with j == 0, then all images in "sphere of interest"
    // have been tested, so no need to find distances for higher values of i.
    if (j == 0) break;
  }

  // Free allocated memory
  free(h);
  free(x.distSq);
  free(y.distSq);
  free(z.distSq);
  free(x.refCoef);
  free(y.refCoef);
  free(z.refCoef);

  return 0;
}
