/* copymodulecrc */

/*
 * Copyright (C) 2014 CUBE
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>


int main(int argc, char **argv) {
	struct stat st;
	off_t filesize;
	int fd;
	char *data, *pos;
	unsigned int i;
	int bFound;
	unsigned long crcval;

	if (argc != 3) {
		printf("usage: copymodulecrc [modulename(src)] [modulename(dst)]\n");
		return -1;
	}

	if (stat(argv[1], &st) != 0) {
		fprintf(stderr, "module1 stat failed.\n");
		return -1;
	}
	filesize = st.st_size;
	fd = open(argv[1], O_RDONLY);
	if (fd < 0) {
		fprintf(stderr, "module1 open failed.\n");
		return -1;
	}
	data = mmap(NULL, filesize, PROT_READ, MAP_SHARED, fd, 0);
	if (data == MAP_FAILED) {
		fprintf(stderr, "module1 mmap failed.\n");
		close(fd);
		return -1;
	}
	pos = data;
	bFound = 0;
	for (i = 0; i < (filesize - 12); ++i) {
		if (memcmp((void *)pos, (void *)"module_layout", 13) == 0) {
			bFound = 1;
			break;
		}
		pos++;
	}
	if (bFound == 0) {
		fprintf(stderr, "module1 crc not found.\n");
		munmap(data, filesize);
		close(fd);
		return -1;
	}

	pos -= 4;
	memcpy((void *)&crcval, (void *)pos, 4);

	munmap(data, filesize);
	close(fd);

	printf("module crc=%08x\n", (unsigned int)crcval);

	if (stat(argv[2], &st) != 0) {
		fprintf(stderr, "module2 stat failed.\n");
		return -1;
	}
	filesize = st.st_size;
	fd = open(argv[2], O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "module2 open failed.\n");
		return -1;
	}
	data = mmap(NULL, filesize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (data == MAP_FAILED) {
		fprintf(stderr, "module2 mmap failed.\n");
		close(fd);
		return -1;
	}
	pos = data;
	bFound = 0;
	for (i = 0; i < (filesize - 12); ++i) {
		if (memcmp((void *)pos, (void *)"module_layout", 13) == 0) {
			bFound = 1;
			break;
		}
		pos++;
	}
	if (bFound == 0) {
		fprintf(stderr, "module2 crc not found.\n");
		munmap(data, filesize);
		close(fd);
		return -1;
	}

	pos -= 4;
	memcpy((void *)pos, (void *)&crcval, 4);

	munmap(data, filesize);
	close(fd);

	printf("module crc copied.\n");

	return 0;
}
