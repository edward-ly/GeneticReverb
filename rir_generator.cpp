/*
Program     : Room Impulse Response Generator
 
Description : Computes the response of an acoustic source to one or more
              microphones in a reverberant room using the image method [1,2].
 
              [1] J.B. Allen and D.A. Berkley,
              Image method for efficiently simulating small-room acoustics,
              Journal Acoustic Society of America, 65(4), April 1979, p 943.
 
              [2] P.M. Peterson,
              Simulating the response of multiple microphones to a single
              acoustic source in a reverberant room, Journal Acoustic
              Society of America, 80(5), November 1986.
 
Author      : dr.ir. E.A.P. Habets (ehabets@dereverberation.org)
Editor		: Edward Ly
 
Version     : 2.2.0

 
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#define _USE_MATH_DEFINES

#include "matrix.h"
#include "mex.h"
#include "math.h"

#define ROUND(x) ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

#ifndef M_PI 
    #define M_PI 3.14159265358979323846 
#endif

double sinc(double x) {
    if (x == 0) return(1.);
    return(sin(x) / x);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs == 0) {
        mexPrintf("--------------------------------------------------------------------\n"
            "| Room Impulse Response Generator                                  |\n"
            "|                                                                  |\n"
            "| Computes the response of an acoustic source to one or more       |\n"
            "| microphones in a reverberant room using the image method [1,2].  |\n"
            "|                                                                  |\n"
            "| Author    : dr.ir. Emanuel Habets (ehabets@dereverberation.org)  |\n"
            "|                                                                  |\n"
            "| Version   : 2.1.20141124                                         |\n"
            "|                                                                  |\n"
            "| Copyright (C) 2003-2014 E.A.P. Habets, The Netherlands.          |\n"
            "|                                                                  |\n"
            "| [1] J.B. Allen and D.A. Berkley,                                 |\n"
            "|     Image method for efficiently simulating small-room acoustics,|\n"
            "|     Journal Acoustic Society of America,                         |\n"
            "|     65(4), April 1979, p 943.                                    |\n"
            "|                                                                  |\n"
            "| [2] P.M. Peterson,                                               |\n"
            "|     Simulating the response of multiple microphones to a single  |\n"
            "|     acoustic source in a reverberant room, Journal Acoustic      |\n"
            "|     Society of America, 80(5), November 1986.                    |\n"
            "--------------------------------------------------------------------\n\n"
            "function [h, beta_hat] = rir_generator(c, fs, r, s, L, beta, nsample,\n"
            " order, hp_filter);\n\n"
            "Input parameters:\n"
            " c           : sound velocity in m/s.\n"
            " fs          : sampling frequency in Hz.\n"
            " r           : 1 x 3 array specifying the (x,y,z) coordinates of the\n"
            "               receiver in m.\n"
            " s           : 1 x 3 vector specifying the (x,y,z) coordinates of the\n"
            "               source in m.\n"
            " L           : 1 x 3 vector specifying the room dimensions (x,y,z) in m.\n"
            " beta        : reverberation time (T_60) in seconds.\n"
            " nsample     : number of samples to calculate, default is T_60*fs.\n"
            " order       : reflection order, default is -1, i.e. maximum order.\n"
            " hp_filter   : use 'false' to disable high-pass filter, the high-pass filter\n"
            "               is enabled by default.\n\n"
            "Output parameters:\n"
            " h           : nsample x 1 column vector containing the calculated room impulse\n"
            "               response.\n"
            " beta_hat    : In case a reverberation time is specified as an input parameter\n"
            "               the corresponding reflection coefficient is returned.\n\n");
        return;
    }

    // Check for proper number of arguments
    if (nrhs < 6)
        mexErrMsgTxt("Error: There are at least six input parameters required.");
    if (nrhs > 9)
        mexErrMsgTxt("Error: Too many input arguments.");
    if (nlhs > 2)
        mexErrMsgTxt("Error: Too many output arguments.");

    // Check for proper arguments
    if (!(mxGetN(prhs[0])==1) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
        mexErrMsgTxt("Invalid input arguments!");
    if (!(mxGetN(prhs[1])==1) || !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]))
        mexErrMsgTxt("Invalid input arguments!");
    if (!(mxGetN(prhs[2])==3) || !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]))
        mexErrMsgTxt("Invalid input arguments!");
    if (!(mxGetN(prhs[3])==3) || !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]))
        mexErrMsgTxt("Invalid input arguments!");
    if (!(mxGetN(prhs[4])==3) || !mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]))
        mexErrMsgTxt("Invalid input arguments!");
    if (!(mxGetN(prhs[5])==1) || !mxIsDouble(prhs[5]) || mxIsComplex(prhs[5]))
        mexErrMsgTxt("Invalid input arguments!");

    // Load parameters
    double        c = mxGetScalar(prhs[0]);
    double        fs = mxGetScalar(prhs[1]);
    const double* rr = mxGetPr(prhs[2]);
    const double* ss = mxGetPr(prhs[3]);
    const double* LL = mxGetPr(prhs[4]);
    double        reverberation_time = mxGetScalar(prhs[5]);
    double        beta;
    int           nSamples;
    int           nOrder;
    int           isHighPassFilter;

    // Reverberation time to reflection coefficient
	if (reverberation_time > 0) {
		double V = LL[0] * LL[1] * LL[2]; // room volume
		double S = 2 * (LL[0]*LL[2] + LL[1]*LL[2] + LL[0]*LL[1]); // room surface area
		double alfa = 24 * V * log(10.0) / (c * S * reverberation_time); // Sabin-Franklin's formula
		if (alfa > 1)
			mexErrMsgTxt("Error: The reflection coefficients cannot be calculated using the current "
						 "room parameters, i.e. room size and reverberation time.\n           Please "
						 "specify the reflection coefficients or change the room parameters.");
		beta = sqrt(1 - alfa);
	} 
	else {
		mexErrMsgTxt("Error: Reverberation time must be positive.\n");
	}

    // High-pass filter (optional)
    if (nrhs > 8 && mxIsEmpty(prhs[8]) == false) {
        isHighPassFilter = (int) mxGetScalar(prhs[8]);
    }
    else {
        isHighPassFilter = 1;
    }

    // Reflection order (optional)
    if (nrhs > 7 && mxIsEmpty(prhs[7]) == false) {
        nOrder = (int) mxGetScalar(prhs[7]);
        if (nOrder < -1)
            mexErrMsgTxt("Invalid input arguments!");
    }
    else {
        nOrder = -1;
    }

    // Number of samples (optional)
    if (nrhs > 6 && mxIsEmpty(prhs[6]) == false) {
        nSamples = (int) mxGetScalar(prhs[6]);
    }
    else {
        nSamples = (int) (reverberation_time * fs);
    }

    // Create output vector
    plhs[0] = mxCreateDoubleMatrix(nSamples, 1, mxREAL);
    double* imp = mxGetPr(plhs[0]);

    // Temporary variables and constants (image-method)
    // const double Fc = 1; // The cut-off frequency equals fs/2 - Fc is the normalized cut-off frequency.
    const int    Tw = 2 * ROUND(0.004 * fs); // The width of the low-pass FIR equals 8 ms
    const double cTs = c / fs;
    double*      LPI = new double[Tw];
    double       r[3], s[3], L[3];
    double       Rm[3];
    double       Rp_plus_Rm[3]; 
    double       refl[3];
    double       fdist, dist, ndist;
    double       gain;
    int          startPosition;
    int          n1, n2, n3;
    int          mx, my, mz, q, j, k, n;

    s[0] = ss[0] / cTs; s[1] = ss[1] / cTs; s[2] = ss[2] / cTs;
    L[0] = LL[0] / cTs; L[1] = LL[1] / cTs; L[2] = LL[2] / cTs;
	// [x_1 x_2 ... x_N y_1 y_2 ... y_N z_1 z_2 ... z_N]
	r[0] = rr[0] / cTs; r[1] = rr[1] / cTs; r[2] = rr[2] / cTs;

	n1 = (int) ceil(nSamples / (2 * L[0]));
	n2 = (int) ceil(nSamples / (2 * L[1]));
	n3 = (int) ceil(nSamples / (2 * L[2]));

	// Generate room impulse response
	for (mx = -n1; mx <= n1; mx++) {
		Rm[0] = 2 * mx * L[0];

		for (my = -n2; my <= n2; my++) {
			Rm[1] = 2 * my * L[1];

			for (mz = -n3; mz <= n3; mz++) {
				Rm[2] = 2 * mz * L[2];

				for (q = 0; q <= 1; q++) {
					Rp_plus_Rm[0] = (1 - 2*q) * s[0] - r[0] + Rm[0];
					refl[0] = pow(beta, abs(mx - q)) * pow(beta, abs(mx));

					for (j = 0; j <= 1; j++) {
						Rp_plus_Rm[1] = (1 - 2*j) * s[1] - r[1] + Rm[1];
						refl[1] = pow(beta, abs(my - j)) * pow(beta, abs(my));

						for (k = 0; k <= 1; k++) {
							Rp_plus_Rm[2] = (1 - 2*k) * s[2] - r[2] + Rm[2];
							refl[2] = pow(beta, abs(mz - k)) * pow(beta, abs(mz));

							dist = sqrt(pow(Rp_plus_Rm[0], 2) + pow(Rp_plus_Rm[1], 2) + pow(Rp_plus_Rm[2], 2));

							if (abs(2*mx - q) + abs(2*my - j) + abs(2*mz - k) <= nOrder || nOrder == -1) {
								fdist = floor(dist);
								if (fdist < nSamples) {
									gain = refl[0] * refl[1] * refl[2] / (4 * M_PI * dist * cTs);

									for (n = 0; n < Tw; n++) {
										ndist = n + 1 - dist + fdist;
										LPI[n] =  0.5 * (1 - cos(2 * M_PI * (ndist / Tw))) * sinc(M_PI * (ndist - (Tw / 2)));
									}

									startPosition = (int) fdist - (Tw / 2) + 1;
									for (n = 0; n < Tw; n++) {
										if (startPosition >= 0 && startPosition < nSamples)
											imp[startPosition] += gain * LPI[n];
										startPosition++;
									}
								}
							}
						}
					}
				}
			}
		}
	}

	// 'Original' high-pass filter as proposed by Allen and Berkley.
	if (isHighPassFilter == 1) {
		// Temporary variables and constants (high-pass filter)
		const double W = 2 * M_PI * 100 / fs; // The cut-off frequency equals 100 Hz
		const double R1 = exp(-W);
		const double B1 = 2 * R1 * cos(W);
		const double B2 = -R1 * R1;
		const double A1 = -(1 + R1);
		double       X0;
		double       Y[3];

		for (int i = 0; i < 3; i++) { Y[i] = 0; }            
		for (int i = 0; i < nSamples; i++) {
			X0 = imp[i];
			Y[2] = Y[1];
			Y[1] = Y[0];
			Y[0] = B1*Y[1] + B2*Y[2] + X0;
			imp[i] = Y[0] + A1*Y[1] + R1*Y[2];
		}
	}
    
    if (nlhs > 1) {
        plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
        double* beta_hat = mxGetPr(plhs[1]);
        beta_hat[0] = beta;
    }
    
    delete[] LPI;
}