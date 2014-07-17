// Converts .zd files to raw binary - either the entire file
// or specific range.
//
// Usage: zdextract [ blockno length ] <file.zd >file.img
//
// With no arguments, extracts the entire file, otherwise extracts the
// specified block and length following blocks.
// arguments can be in decimal, octal, or hex, using C number syntax.

#define _LARGEFILE_SOURCE 1
#define _LARGEFILE64_SOURCE 1
#define _FILE_OFFSET_BITS 64

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include "zlib.h"

#ifdef NO_FSEEKO
#define off_t long
#define fseeko fseek
#endif

int main(int argc, char **argv)
{
    char line[LINE_MAX];
    unsigned char *buf;  // EBLOCKSIZE
    long          eblocks = -1;
    int           eblocknum;
    long          buflen;

    int           zresult;
    uLongf        zlen;
    long          zblocksize, zbufsize;
    unsigned char *zbuf;
    int           thisarg;
    int           want_start = -1;
    int           want_end = -1;

    thisarg = 1;
    if (thisarg < argc) {
        want_start = want_end = strtol(argv[thisarg], 0, 0);
        thisarg++;
        if (thisarg < argc) {
            want_end = want_start + strtol(argv[thisarg], 0, 0);
            thisarg++;
        }
    }

    while (fgets(line, LINE_MAX, stdin) != NULL) {
        if (sscanf(line, "zblock: %x %lx", &eblocknum, &zlen) == 2) {
            if (want_start == -1 ||
                (eblocknum >= want_start && eblocknum <= want_end)) {
                fprintf(stderr, "\r%.4x", eblocknum);
                fflush(stderr);
                if (fread(zbuf, 1, zlen, stdin) != zlen) {
                    fprintf(stderr, "Short read at block 0x%x\n", eblocknum);
                    exit(1);
                }
                buflen = zblocksize;
                if ((zresult = uncompress(buf, &buflen, zbuf, zlen)) != Z_OK) {
                    fprintf(stderr,
                            "Uncompress failure at block 0x%x - %d\n",
                            eblocknum, zresult);
                }
                if (buflen != zblocksize) {
                    fprintf(stderr,
                            "Uncompressed buffer bad size (%ld) at block 0x%x\n",
                            buflen, eblocknum);
                }
                if (fseeko(stdout, (off_t)(eblocknum - want_start) * (off_t)zblocksize,
                           SEEK_SET)) {
                    perror("fseek");
                    exit(1);
                }
                if (fwrite(buf, 1, buflen, stdout) < buflen) {
                    perror("fwrite");
                    exit(1);
                }
            } else {
                fseek(stdin, zlen+1, SEEK_CUR);
            }
        }
        if (sscanf(line, "zblocks: %lx %lx", &zblocksize, &eblocks) == 2) {
            buf = malloc(zblocksize);
            /*
             * For zlib compress, the destination buffer needs to be
             * 1.001 x the src buffer size plus 12 bytes
             */
            zbufsize = ((zblocksize * 102) / 100) + 12;
            zbuf = malloc(zbufsize);
        }
    }

  out:
    fprintf(stderr, "\n");
    return 0;
}
