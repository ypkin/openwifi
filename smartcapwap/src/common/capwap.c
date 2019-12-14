#include "capwap.h"

/* Helper exit */
void capwap_exit(int errorcode) {
	exit(errorcode);
}

/* Get random number */
int capwap_get_rand(int max) {
	if ((max < 0) || (max > RAND_MAX)) {
		max = RAND_MAX;
	}

	return (rand() % max);
}

/* Duplicate string */
char* capwap_duplicate_string(const char* source) {
	char* clone;

	ASSERT(source != NULL);

	clone = capwap_alloc(strlen(source) + 1);
	strcpy(clone, source);

	return clone;
}

/* Buffer clone */
void* capwap_clone(const void* buffer, int buffersize) {
	void* bufferclone;
	
	ASSERT(buffer != NULL);
	ASSERT(buffersize > 0);

	bufferclone = capwap_alloc(buffersize);
	return memcpy(bufferclone, buffer, buffersize);
}

/* */
char* capwap_itoa(int input, char* output) {
	sprintf(output, "%d", input);
	return output;
}

/* */
char* capwap_ltoa(long input, char* output) {
	sprintf(output, "%ld", input);
	return output;
}
