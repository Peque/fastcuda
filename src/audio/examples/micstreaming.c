/*
 * micstreaming.c
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
#include <AL/al.h>
#include <AL/alc.h>


#define N_BUFFERS 6
#define FREQ 44100


ALCdevice *dev[2];          // Input and output devices
int buffers_processed;
int i;


int main()
{
	ALCcontext *ctx;
	ALuint source, buffers[N_BUFFERS];
	char data[2000];
	ALuint buf;

	dev[0] = alcOpenDevice(NULL);

	ctx = alcCreateContext(dev[0], NULL);
	alcMakeContextCurrent(ctx);

	alGenSources(1, &source);
	alGenBuffers(N_BUFFERS, buffers);

	for (i = 0; i < N_BUFFERS; i++) {
		alBufferData(buffers[i], AL_FORMAT_MONO16, data, sizeof(data), FREQ);
	}

	alSourceQueueBuffers(source, N_BUFFERS, buffers);

	dev[1] = alcCaptureOpenDevice(NULL, FREQ, AL_FORMAT_MONO16, sizeof(data)/2);

	alSourcePlay(source);
	alcCaptureStart(dev[1]);

	while(1) {

		// Check number of processed buffers
		alGetSourcei(source, AL_BUFFERS_PROCESSED, &buffers_processed);

		if(buffers_processed <= 0) {
			usleep(10000);
			continue;
		}

		alcGetIntegerv(dev[1], ALC_CAPTURE_SAMPLES, 1, &buffers_processed);

		// Read captured audio
		alcCaptureSamples(dev[1], data, buffers_processed);

		alSourceUnqueueBuffers(source, 1, &buf);
		alBufferData(buf, AL_FORMAT_MONO16, data, buffers_processed*2, FREQ);
		alSourceQueueBuffers(source, 1, &buf);

		// Check if the source is still playing
		alGetSourcei(source, AL_SOURCE_STATE, &buffers_processed);
		if (buffers_processed != AL_PLAYING) alSourcePlay(source);

	}

	alcCaptureStop(dev[1]);
	alcCaptureCloseDevice(dev[1]);

	alSourceStop(source);
	alDeleteSources(1, &source);
	alDeleteBuffers(N_BUFFERS, buffers);

	alcMakeContextCurrent(NULL);
	alcDestroyContext(ctx);
	alcCloseDevice(dev[0]);

	return 0;
}
