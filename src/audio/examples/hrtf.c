/*
 * hrtf.c
 *
 * Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "AL/al.h"
#include "AL/alut.h"
#include "SDL/SDL.h"


#define SAMPLES 128

// Listener
ALfloat listener_position[] = { 0.0, 0.0, 0.0 };
ALfloat listener_speed[] = { 0.0, 0.0, 0.0 };
ALfloat	listener_orientation[] = { 0.0, 0.0, 1.0, 0.0, 1.0, 0.0 }; // Default listener orientation
/*
 * Important!: -x is left, +x is right, -z is front, and +z is back (like OpenGL's coordinates)
 */

ALfloat source_position[]={ 0.0, 0.0, 1.0};
ALfloat source_speed[]={ 0.0, 0.0, 1.0 };

// Source
ALuint buffer;
ALuint source;

// General
SDL_AudioSpec wav_spec;
Uint32 size;
Uint8 *audio_buffer;
ALenum source_state;
FILE *fp;
char hrir_file[100];
int16_t hrir_data[2 * SAMPLES];
float hrir_data_real[2 * SAMPLES];
int i, j;


int main(int argc, char *argv[])
{

	int ch,error;

	// Check for correct parameters
	if (argc != 2) {
		printf("Usage: hrtf <mono_audio_file.wav>\n");
		exit(1);
	}

	// Initialize OpenAL
	alutInit(NULL, 0);

	// Generate buffer
	alGenBuffers(1, &buffer);

	// Check for errors
	if ((error = alGetError()) != AL_NO_ERROR) {
		printf("Can not create the buffer\n");
		exit(1);
	}

	// Load sound
	if (SDL_LoadWAV(argv[1], &wav_spec, &audio_buffer, &size) == NULL) {
		printf("Error loading %s\n", argv[1]);
		exit(1);
	}

/* ***************************************************************************************** *
	// Apply HRTF to the buffer
	strcpy(hrir_file, "./kemar_hrtf/compact/elev0/H0e090a.dat");

	if (!(fp = fopen(hrir_file, "r"))) {
		printf("Could not open %s!", hrir_file);
		exit(1);
	}

	fread(hrir_data, 2, 2 * SAMPLES, fp);

	// Check for little endian system:
	i = 1;
	if (*(char *) &i == 1) {
		// Convert data to little endian format
		printf("Converting HRIR data to little endian...\n");
		for (i = 0; i < 2 * SAMPLES; i ++) {
			hrir_data[i] = ((uint16_t) hrir_data[i] << 8) | (hrir_data[i] >> 8);
		}
	}

	for (i = 0; i < 2 * SAMPLES; i += 2) {
		printf("Left: %6d   Right: %6d\n", hrir_data[i], hrir_data[i + 1]);
	}

	// Convert 16 bits integer data to real € [ -1, 1 ]
	for (i = 0; i < 2 * SAMPLES; i += 2) {
		hrir_data_real[i] = hrir_data[i] / 32768.0f;
		hrir_data_real[i + 1] = hrir_data[i + 1] / 32768.0f;
	}

	printf("========================================================%d\n", size);

	for (i = 0; i < 2 * SAMPLES; i += 2) {
		printf("Left: %6f   Right: %6f\n", hrir_data_real[i], hrir_data_real[i + 1]);
	}

	int16_t *i16p;
	i16p = (int16_t *) buffer;

	for (i = 0; i < size - 2 * SAMPLES; i+=2) {
		for (j = 0; j < 2 * SAMPLES; j += 2) {
			(i16p*) += ((i16p+j)*) * hrir_data_real[j];
			((i16p+1)*) += ((i16p+j+1)*) * hrir_data_real[j+1];
		}
		i16p += 2;
	}
/* ***************************************************************************************** */

	// Move sound data to the buffer
	alBufferData(buffer, AL_FORMAT_STEREO16, audio_buffer, size, wav_spec.freq);

	// Free the loaded file
	SDL_FreeWAV(audio_buffer);

	// Generate the source
	alGenSources(1, &source);

	// Check for errors
	if ((error = alGetError()) != AL_NO_ERROR) {
		printf("Can not create the source...\n");
		exit(1);
	}

	// Listener properties
	alListenerfv(AL_POSITION, listener_position);
	alListenerfv(AL_VELOCITY, listener_speed);
	alListenerfv(AL_ORIENTATION, listener_orientation);

	// Source properties
	alSourcefv(source, AL_POSITION, source_position);
	alSourcefv(source, AL_VELOCITY, source_speed);
	alSourcei(source, AL_BUFFER, buffer);

	alSourcePlay(source);

	while (1) {
		alGetSourcei(source, AL_SOURCE_STATE, &source_state);
		if (source_state != AL_PLAYING) break;
		usleep(10000);
	}

	// Stop source
	alSourceStop(source);

	// Cleaning
	alDeleteSources(1, &source);
	alDeleteBuffers(1, &buffer);

	// Exit OpenAL
	alutExit();

	return 0;
}
