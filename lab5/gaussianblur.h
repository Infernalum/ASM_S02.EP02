#ifndef _GAUSSIANBLUR_H_
#define _GAUSSIANBLUR_H_

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <time.h>
#include "lodepng/lodepng.h"

const int ker_size = 3;

const double sigma = 1.0 / 16;

static const double ker[3][3] = {
{ 1, 2, 1 },
{ 2, 4, 2 },
{ 1, 2, 1 }
};


int encodeImage(const char*, const unsigned char*, const unsigned, const unsigned);
int decodeImage(const char*, unsigned char**, unsigned*, unsigned*);
char* newFilename(const char*);
unsigned char* imageExpansion(const char*, unsigned*, unsigned*);
void applyGauss(unsigned char*, unsigned, unsigned, unsigned char*);
void applyGaussAsm(unsigned char*, unsigned, unsigned, unsigned char*);
#endif // !_GAUSSIANBLUR_H_

