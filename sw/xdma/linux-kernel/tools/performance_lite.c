/*
 * This file is part of the Xilinx DMA IP Core driver tools for Linux
 *
 * Copyright (c) 2016-present,  Xilinx, Inc.
 * All rights reserved.
 *
 * This source code is licensed under BSD-style license (found in the
 * LICENSE file in the root directory of this source tree)
 */

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <limits.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "../xdma/cdev_sgdma.h"

struct xdma_performance_ioctl perf;

static struct option const long_opts[] =
{
  {"device", required_argument, NULL, 'd'},
  {"count", required_argument, NULL, 'c'},
  {"size", required_argument, NULL, 's'},
  {"freq", required_argument, NULL, 'f'},
  {"incremental", no_argument, NULL, 'i'},
  {"non-incremental", no_argument, NULL, 'n'},
  {"verbose", no_argument, NULL, 'v'},
  {"help", no_argument, NULL, 'h'},
  {0, 0, 0, 0}
};

static void usage(const char* name)
{
  int i = 0;
  printf("%s\n\n", name);
  printf("usage: %s [OPTIONS]\n\n", name);
  printf("Performance test for XDMA SGDMA engine.\n\n");

  printf("  -%c (--%s) device\n", long_opts[i].val, long_opts[i].name); i++;
  printf("  -%c (--%s) incremental\n", long_opts[i].val, long_opts[i].name); i++;
  printf("  -%c (--%s) non-incremental\n", long_opts[i].val, long_opts[i].name); i++;
  printf("  -%c (--%s) xdma axi clock frequency\n", long_opts[i].val, long_opts[i].name); i++;
  printf("  -%c (--%s) be more verbose during test\n", long_opts[i].val, long_opts[i].name); i++;
  printf("  -%c (--%s) print usage help and exit\n", long_opts[i].val, long_opts[i].name); i++;
}

static uint32_t getopt_integer(char *optarg)
{
  int rc;
  uint32_t value;
  rc = sscanf(optarg, "0x%x", &value);
  if (rc <= 0)
    rc = sscanf(optarg, "%ul", &value);
  return value;
}

int test_dma(char *device_name, int size, int count, int freq);

static int verbosity = 0;

int main(int argc, char *argv[])
{
  int cmd_opt;
  char *device = "/dev/xdma/card0/h2c0";
  uint32_t size = 32768;
  uint32_t count = 1;
  uint32_t freq = 250;  // AXI Clock Frequency MHz
  char *filename = NULL;

  while ((cmd_opt = getopt_long(argc, argv, "vhic:d:s:f:", long_opts, NULL)) != -1)
  {
    switch (cmd_opt)
    {
      case 0:
        /* long option */
        break;
      case 'v':
        verbosity++;
        break;
      /* device node name */
      case 'd':
        printf("'%s'\n", optarg);
        device = strdup(optarg);
        break;
      /* transfer size in bytes */
      case 's':
        size = getopt_integer(optarg);
        break;
      /* count */
      case 'c':
        count = getopt_integer(optarg);
        break;
      /* xdma axi freq (maybe 250MHz) */
      case 'f':
        freq = getopt_integer(optarg);
        break;
      /* print usage help and exit */
      case 'h':
      default:
        usage(argv[0]);
        exit(0);
        break;
    }
  }
  printf("\tdevice = %s, size = 0x%08x, count = %u\n", device, size, count);
  test_dma(device, size, count, freq);

}

int test_dma(char *device_name, int size, int count, int freq)
{
  int rc = 0;
  int fd = open(device_name, O_RDWR);
  if (fd < 0) {
	  printf("\tFAILURE: Could not open %s. Make sure xdma device driver is loaded and you have access rights (maybe use sudo?).\n", device_name);
	  exit(1);
  }

  unsigned char status = 1;

  perf.version = IOCTL_XDMA_PERF_V1;
  perf.transfer_size = size;
  rc = ioctl(fd, IOCTL_XDMA_PERF_START, &perf);
#if 1
  while (count--) {

    sleep(2);
    rc = ioctl(fd, IOCTL_XDMA_PERF_GET, &perf);
  }
#endif
  rc = ioctl(fd, IOCTL_XDMA_PERF_STOP, &perf);
  long long data_transferred = (long long)perf.transfer_size * (long long)perf.iterations;
  long double data_rate = 0;
  long long data_duty_cycle = 0;

  if ((long long)perf.clock_cycle_count != 0) {
    data_rate = (long double) data_transferred * (long double) freq / (long double)perf.clock_cycle_count / 1000;
    data_duty_cycle = (long long)perf.data_cycle_count * 100 / (long long)perf.clock_cycle_count;
  }
  printf("\t \033[;32m Date Rate = %Lf GBytes/s\033[0m, data duty cycle = %lld%%\n\n", data_rate, data_duty_cycle);

  close(fd);
}

