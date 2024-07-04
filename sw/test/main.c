#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/uio.h>
#include <stdarg.h>
#include <time.h>

void usage(char *program_name)
{
    printf("Usage: %s <dev_name> <test_mode> [<size>]\n", program_name);
    printf("\tdev_name: /dev/sdma_dev0, /dev/sdma_dev1, /dev/sdma_dev2, /dev/sdma_dev3.\n");
    printf("\ttest_mode: 0 indicates read and write check. 1 indicates readv and wirtev check. 2 indicates partial reconfiguration.\n");
}

void test_rw(int fd, int size)
{
    int cnt;
    char *buf = malloc(size);
    if (buf == NULL)
    {
        printf("cann't malloc\n");
        goto fail;
    }

    for (int i = 0; i < size; i++)
    {
        buf[i] = i;
    }

    cnt = write(fd, buf, size);
    if (cnt != size)
    {
        printf("write error\n");
        goto fail;
    }

    /*offset is redefined as the starting of device file*/
    lseek(fd, 0, SEEK_SET);

    cnt = read(fd, buf, size);
    if (cnt != size)
    {
        printf("read error\n");
        goto fail;
    }

    for (int i = 0; i < size; i++)
    {
        if (buf[i] != i)
        {
            printf("data error\n");
            goto fail;
        }
    }
    printf("Test0: %d bytes read and write test, check successfully.\n", size);
    printf("Test passed.\n");
    free(buf);
    return;
fail:
{
    printf("Info: Test failed.\n");
    free(buf);
}
}

void test_rwv(int fd, int num)
{
    if (fd < 0) {
        printf("open file failed!\n");
        return ;
    }

    struct iovec wiov[64], riov[64];
    ssize_t nwritten, nread;

    int size[64];
    int i, j;
    srand(time(NULL));
    for (i = 0; i < num; i++)
    {
        size[i] = rand() % 64;
    }

    // writev
    for (i = 0; i < num; i++)
    {
        wiov[i].iov_len = size[i];
        char * iov_base = malloc(wiov[i].iov_len);
        for (j = 0; j < i; j++)
        {
            iov_base[j] = j;
        }
         wiov[i].iov_base = iov_base;
    }

    nwritten = writev(fd, wiov, num);

    // readv
    for (i = 0; i < num; i++)
    {
        riov[i].iov_len = size[i];
        riov[i].iov_base = malloc(riov[i].iov_len);
    }

    nread = readv(fd, riov, num);

    for (i = 0; i < num; i++)
    {
        if (wiov[i].iov_len != size[i] || riov[i].iov_len != size[i])
        {
            goto fail;
        }
        if (!memcpy((char*)wiov[i].iov_base, (char*)riov[i].iov_base, wiov[i].iov_len))
        {
            goto fail;
        }
    }

    for (i = 0; i < num; i++)
    {
        free(wiov[i].iov_base);
        free(riov[i].iov_base);
    }
    printf("Test1: %d buffer, %ld bytes readv and writev test, check successfully.\n", num, nread);
    printf("Test passed.\n");
    return;
fail:
{
    for (i = 0; i < num; i++)
    {
        free(wiov[i].iov_base);
        free(riov[i].iov_base);
    }
    printf("Info: Test failed.\n");
}
}

void test_wfile(int fd, char *bitstream)
{
    FILE *wfile;
    char buffer[4096]; // 使用4096字节的缓冲区
    size_t bytes;

    wfile = fopen(bitstream, "rb");
    if (wfile == NULL) {
        fprintf(stderr, "Error opening wfile.\n");
        return;
    }

    while ((bytes = fread(buffer, 1, sizeof(buffer), wfile)) > 0) {
        write(fd, buffer, bytes);
    }

    if (ferror(wfile)) {
        fprintf(stderr, "Error reading from input file.\n");
    }

    fclose(wfile);
}

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        goto fail0;
    }
    /*argv[1] is device file path*/
    int fd = open(argv[1], O_RDWR);
    if (fd < 0)
    {
        printf("open file failed!\n");
        return -1;
    }

    /*argv[2] is test mode*/
    switch (strtol(argv[2], NULL, 0))
    {
    case 0:  // read/write
    {
        if (argc < 4)
        {
            goto fail0;
        }
        test_rw(fd, strtol(argv[3], NULL, 0));
        break;
    }
    case 1:  // readv/writev
    {
        if (argc != 4)
        {
            goto fail0;
        }
        test_rwv(fd, strtol(argv[3], NULL, 0));
        break;
    }
    case 2:  // write file
    {
        if (argc != 4)
        {
            goto fail0;
        }
        test_wfile(fd, argv[3]);
        break;
    }
    default:
        break;
    }

    close(fd);
    return 0;

fail0:
{
    printf("parameter error\n");
    usage(argv[0]);
    close(fd);
    return -1;
}
}