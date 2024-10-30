#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <sys/types.h>

void sys_ready();
void sys_process();
void sys_stop();

void reg_read();
void reg_write();

void dma_to_card();
void dma_to_host();

void dma_bypass_to_card_bypass();
void dma_bypass_to_host_bypass();

void interrupt_ctrl();    // enable/disable
void interrupt_get();    // get specified interrupt
void interrupt_clear();    // clear interrupt




