/***************************************************************************
                          tut1.c  -  description
                             -------------------
    begin                : vie 5 Dic 2003
    copyright            : (C) 2003 by Jorge Bernal Martinez
    email                : lordloki@users.berlios.de
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "AL/al.h"
#include "AL/alut.h"
#include "SDL/SDL.h"

/* Defino variables del oyente y de la fuente */
ALfloat oyente_posicion[]={0.0,0.0,0.0};
ALfloat oyente_velocidad[]={0.0,0.0,0.0};
ALfloat	oyente_origen[]={0.0,0.0,1.0,0.0,1.0,0.0};

ALfloat fuente_posicion[]={ 0.0, 0.0, 1.0};
ALfloat fuente_velocidad[]={ 0.0, 0.0, 1.0};

ALuint	buffer;
ALuint	fuente;

/* Defino variables para la carga de sonidos */
SDL_AudioSpec wav_spec;
Uint32 size;
Uint8 *datos;


/* Funcion principal*/
int main(int argc, char* argv[])
{

	/* Variables locales */
	int ch,error;

	/* Vemos si se han pasado los parametros correctos */
	if (argc < 2){
		printf("Para reproducir un sonido escribe:\n");
		printf("./tut1 sonido.wav\n");
		printf("Donde sonido.wav es el nombre de tu archivo wav\n");
		exit(1);
	}

	/* Mostramos los controles del reproductor */
	printf("Pulsa '1' y 'enter' para oir el archivo\n");
	printf("Pulsa '2' y 'enter' para parar el archivo\n");
	printf("Pulsa 'q' y 'enter' para salir\n");

	/* Inicializamos OpenAL */
	alutInit(NULL,0);

	/* Generamos el buffer */
	alGenBuffers(1,&buffer);

	/* Comprobamos si ha habido algun error */
	if ((error = alGetError()) != AL_NO_ERROR){
		printf("No se puede crear el buffer\n");
		exit(1);
	}

	/* Cargamos el sonido */
	if ( SDL_LoadWAV(argv[1], &wav_spec,&datos,&size)== NULL ){
		printf("Error al cargar %s\n",argv[1]);
		exit(1);
	}

	/* Pasamos el sonido cargado al buffer */
        alBufferData(buffer,AL_FORMAT_STEREO16,datos,size,wav_spec.freq);

	/* Liberamos el sonido cargado */
	SDL_FreeWAV(datos);

	/* Generamos la fuente */
	alGenSources(1,&fuente);

	/* Comprobamos si ha habido algun error */
	if ((error = alGetError()) != AL_NO_ERROR){
		printf("No se puede crear la fuente\n");
		exit(1);
	}

	/* Definimos las propiedades del oyente */
	alListenerfv(AL_POSITION,oyente_posicion);
	alListenerfv(AL_VELOCITY,oyente_velocidad);
	alListenerfv(AL_ORIENTATION,oyente_origen);

	/* Definimos las propiedades de la fuente */
	alSourcefv(fuente,AL_POSITION,fuente_posicion);
	alSourcefv(fuente,AL_VELOCITY,fuente_velocidad);
	alSourcei(fuente,AL_BUFFER,buffer);

	/* Obtenemos caracteres del teclado para reproducir o parar */
	do
	{
		ch = getchar();
		switch (ch)
		{
			case '1':alSourcePlay(fuente);
				break;
			case '2':alSourceStop(fuente);
				break;
		}
	} while (ch != 'q');

	/* Paramos la fuente antes de finalizar */
	alSourceStop(fuente);

	/* Finalizamos OpenAL */
	alutExit();

	return 0;
}

