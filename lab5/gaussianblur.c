#define _SECURE_NO_WARNINGS
#include "gaussianblur.h"

extern const int ker_size;
extern const double sigma;
extern const double ker[3][3];

int encodeImage(const char* filename, const unsigned char* image,const unsigned width,const unsigned height) {
	unsigned error = lodepng_encode32_file(filename, image, width, height);
	if (error)
		printf("error %u: %s\n", error, lodepng_error_text(error));
	return error;
}

int decodeImage(const char* filename, unsigned char** origin_image,unsigned* width,unsigned* height) {
	unsigned error = lodepng_decode32_file(&(*origin_image), &(*width), &(*height), filename);
	if (error)
		printf("error %u: %s\n", error, lodepng_error_text(error));
	return error;
}


char* newFilename(const char* filename) {
	unsigned length = strlen(filename) + 5;
	char* new_filename = malloc(length);
	for (unsigned i = 0; i < length - 9; ++i)
		new_filename[i] = filename[i];
	new_filename[length - 9] = '_';
	new_filename[length - 8] = 'n';
	new_filename[length - 7] = 'e';
	new_filename[length - 6] = 'w';
	new_filename[length - 5] = '.';
	new_filename[length - 4] = 'p';
	new_filename[length - 3] = 'n';
	new_filename[length - 2] = 'g';
	new_filename[length - 1] = '\0';
	return new_filename;
};

unsigned char* imageExpansion(const char* origin_image, unsigned* width, unsigned* height) {
	unsigned ker_div = ker_size / 2;
	unsigned add_width = { (*width) + 2 * ker_div };
	unsigned add_height = { (*height) + 2 * ker_div };
	unsigned char* add_image = malloc(add_width * add_height * 4);
	unsigned x, y, i;
	// Копируем основную часть
	for (y = ker_div; y < add_height - ker_div; y++)
		for (x = ker_div; x < add_width - ker_div; x++) {
			for (i = 0; i < 4; ++i)
				add_image[4 * add_width * y + 4 * x + i] = origin_image[4 * (*width) * (y - ker_div) + 4 * (x - ker_div) + i];
		};
	// Формирование верхней границы
	for (x = ker_div; x < add_width - ker_div; ++x)
		for (i = 0; i < 4; ++i)
			add_image[4 * x + i] = origin_image[4 * (x - ker_div) + i];
	// Формирование нижней границы 
	for (x = ker_div; x < add_width - ker_div; ++x)
		for (i = 0; i < 4; ++i)
			add_image[4 * (add_width * (add_height - 1) + x) + i] = origin_image[4 * ((*width) * ((*height) - 1) + (x - ker_div)) + i];
	// Формирование левой границы
	for (y = ker_div; y < add_height - ker_div; ++y)
		for (i = 0; i < 4; ++i)
			add_image[4 * (add_width * y) + i] = origin_image[4 * ((*width) * (y - 1)) + i];
	// Формирование правой границы
	for (y = ker_div; y < add_height - ker_div; ++y)
		for (i = 0; i < 4; ++i)
			add_image[4 * ((add_width - 1) * (y + 1) + y) + i] = origin_image[4 * ((*width) * y - 1) + i];
	// Формирование углов
	for (i = 0; i < 4; ++i) {
		// Левый верхний угол
		add_image[i] = (add_image[4 + i] + add_image[4 * add_width + i]) / 2;
		// Правый верхний угол
		add_image[4 * (add_width - 1) + i] = (add_image[4 * (add_width - 2) + i] + add_image[4 * (2 * add_width - 1) + i]) / 2;
		// Левый нижний угол
		add_image[4 * add_width * (add_height - 1) + i] = (add_image[4 * (add_width * (add_height - 2)) + i] + add_image[4 * (add_width * (add_height - 1) + 1) + i]) / 2;
		// Правый нижний угол
		add_image[4 * (add_width * add_height - 1) + i] = (add_image[4 * (add_width * (add_height - 1) - 1) + i] + add_image[4 * (add_height * add_width - 2) + i]) / 2;
	}
	(*width) = add_width;
	(*height) = add_height;
	return add_image;
}





void applyGauss(unsigned char* add_image, unsigned add_width, unsigned add_height, unsigned char* result_image) {
	unsigned ker_div = ker_size / 2;
	for (unsigned y = ker_div; y < add_height - ker_div; ++y)
		for (unsigned x = ker_div; x < add_width - ker_div; ++x)
			for (unsigned i = 0; i < 4; ++i)
				result_image[4 * ((add_width - 2 * ker_div/*ker_size*/) * (y - ker_div) + (x - ker_div)) + i] = sigma * (
					ker[0][0] * add_image[4 * (add_width * (y - 1) + x - 1) + i] +
					ker[0][1] * add_image[4 * (add_width * (y - 1) + x) + i] +
					ker[0][2] * add_image[4 * (add_width * (y - 1) + x + 1) + i] +
					ker[1][0] * add_image[4 * (add_width * y + x - 1) + i] +
					ker[1][1] * add_image[4 * (add_width * y + x) + i] +
					ker[1][2] * add_image[4 * (add_width * y + x + 1) + i] +
					ker[2][0] * add_image[4 * (add_width * (y + 1) + x - 1) + i] +
					ker[2][1] * add_image[4 * (add_width * (y + 1) + x) + i] +
					ker[2][2] * add_image[4 * (add_width * (y + 1) + x + 1) + i]);
}



int main(int argc, char* argv[]) {
	srand(time(NULL));
	const char* filename = argc == 2 ? argv[1] : NULL;
	if (!filename) {
	printf("Usage: \\%s image.png\n", argv[0]);
	return 1;
}
	//cutcut(filename);
	//const char* filename = "pictures/fire.png";
	unsigned char* origin_image = { NULL };
	unsigned width = { 0 }, height = { 0 };
	if (decodeImage(filename, &origin_image, &width, &height))
		return 1;
	unsigned add_width = { width }, add_height = { height };
	clock_t first, last;
	first = clock();
	unsigned char* add_image = imageExpansion(origin_image, &add_width, &add_height);
	last = clock();
	printf("Expansion of image: time = %f;\n", (double)(last - first) / 100000);
	free(origin_image);
	unsigned char* result_image = malloc(width * height * 4);
	first = clock();
	applyGaussAsm(add_image, add_width, add_height, result_image);
	last = clock();
	printf("Apply ASM  Gaussian Blur to added image: time = %f;\n", (double)(last - first) / 1000000);
	first = clock();
	applyGauss(add_image, add_width, add_height, result_image);
	last = clock();
	printf("Apply Gaussian Blur to added image: time = %f;\n", (double)(last - first) / 1000000);
	char* new_filename = newFilename(filename);
	first = clock();
	encodeImage(new_filename, result_image, width, height);
	last = clock();
	printf("Encode result image: time = %f;\n", (double)(last - first) / 1000000);
	free(add_image);
	free(result_image);
	free(new_filename);
	return 0;
}
