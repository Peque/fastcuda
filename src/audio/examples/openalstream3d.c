/*
 * openalstream3d.c
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
#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alut.h>
#include <vorbis/vorbisfile.h>


// General
#define N_SOURCES 1
#define N_BUFFERS 3
#define BUFFER_SIZE 4096

FILE *audio_file;
ALenum audio_format;
ALenum source_state;
int decoded_buffer[BUFFER_SIZE];
int buffers_processed;
int buffer_i;
int current_section;
int audio_end;
int i;

// Buffers and sources
ALuint buffers[N_BUFFERS];
ALuint sources[N_SOURCES];

// Listener
ALfloat listener_position[] = { 0.0, 0.0, 0.0 };
ALfloat listener_speed[] = { 0.0, 0.0, 0.0 };
ALfloat listener_orientation[] = { 0.0, 0.0, 1.0, 0.0, 1.0, 0.0 };

// Source
ALfloat source_position[] = { 0.0, 0.0, 1.0 };
ALfloat source_speed[] = { 0.0, 0.0, 1.0 };


int main (int argc, char **argv)
{
	// Check correct calling
	if (argc != 2) {
		printf("Usage: openalstream3d <audio_file.ogg>\n");
		exit(1);
	}

	// Load the audio file
	if (( audio_file = fopen(argv[1], "r")) == NULL ) {
		printf("ERROR: Could not load %s file!\n", argv[1]);
		exit(1);
	}

	/*
	 * Open Ogg file, and get some information about it.
	 * We are using libogg for this job.
	 */
	OggVorbis_File ogg_file;
	vorbis_info *ogg_file_information = NULL;

	if (ov_open(audio_file, &ogg_file, NULL, 0) < 0) {
		printf("ERROR: Not an Ogg file!\n");
		exit(1);
	}

	// Get Ogg information
	ogg_file_information = ov_info(&ogg_file, -1);

	printf("%s\n", argv[1]);
	printf("%ld Hz\n", ogg_file_information->rate);
	printf("%ld kbps\n", ogg_file_information->bitrate_nominal);
	printf("%d channel(s)\n", ogg_file_information->channels);

	// Set audio format (stereo or mono)
	audio_format = ogg_file_information->channels == 2 ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;

	// OpenAL simple initialization
	alutInit(NULL, 0);

	// Generate buffer
	alGenBuffers(N_BUFFERS, buffers);
	if (alGetError() != AL_NO_ERROR) {
		printf("ERROR: Could not create the buffers!\n");
		exit(1);
	}

	// Generate source
	alGenSources(N_SOURCES, sources);
	if (alGetError() != AL_NO_ERROR) {
		printf("ERROR: Could not create the source/emmiter!\n");
		exit(1);
	}

	current_section = -1;

	// Filling the buffers with decoded music
	for (i = 0; i < N_BUFFERS ; i++) {

		ov_read(&ogg_file, (char *) decoded_buffer, BUFFER_SIZE, 0, 2, 1, &current_section);

		alBufferData(buffers[i], audio_format, decoded_buffer, BUFFER_SIZE, ogg_file_information->rate);
		if (alGetError() != AL_NO_ERROR) printf ("ERROR: Could not fill buffer with decoded audio!\n");

		// TODO: break if audio size is smaller that all buffers (see openalstream.c)

	}

	// Asign buffers to the source
	alSourceQueueBuffers(sources[0], N_BUFFERS, buffers);

	// Avoid looping
	alSourcei(sources[0], AL_LOOPING, AL_FALSE);

	// Start playing!
	alSourcePlay(sources[0]);

	/*
	 * Music streaming
	 */

	audio_end = 0;
	buffers_processed = 0;

	while (!audio_end) {

		// Check number of processed buffers
		alGetSourcei(sources[0], AL_BUFFERS_PROCESSED, &buffers_processed);

		// Unqueue the processed buffer, fill it with data and queue it back
		while (buffers_processed) {

			alSourceUnqueueBuffers(sources[0], 1, &buffer_i);
			if (alGetError() != AL_NO_ERROR) {
				printf("ERROR: Could not unqueue buffer!\n");
				exit(1);
			}

			ov_read(&ogg_file, (char *) decoded_buffer, BUFFER_SIZE, 0, 2, 1, &current_section);

			alBufferData(buffer_i, audio_format, decoded_buffer, BUFFER_SIZE, ogg_file_information->rate);
			if (alGetError() != AL_NO_ERROR) {
				printf("ERROR: Could not add decoded data to the buffer!\n");
				exit(1);
			}

			alSourceQueueBuffers(sources[0], 1, &buffer_i);
			if (alGetError() != AL_NO_ERROR) {
				printf("ERROR: Could not reasign buffer to the queue!\n");
				exit(1);
			}

			buffers_processed--;

			// TODO: break if audio size is smaller that all buffers (see openalstream.c)

		}

		// In case there are no processed buffers, sleep a little
		usleep(10000);

		// Check for a buffer underrun
		alGetSourcei(sources[0], AL_SOURCE_STATE, &source_state);
		if (source_state != AL_PLAYING) {
			audio_end = 1;
			break;
		}
	}

	// Stop source
	alSourceStop(sources[0]);

	// Cleaning
	alDeleteSources(N_SOURCES, sources);
	alDeleteBuffers(N_BUFFERS, buffers);

	// Exit OpenAL
	alutExit();

	return 0;
}
