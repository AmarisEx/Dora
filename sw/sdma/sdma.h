#ifndef __SDMA_H__
#define __SDMA_H__

#include <linux/cdev.h>
#include <linux/pci.h>

#define DRIVER_NAME "sdma"
#define CLASS_NAME "sdma_class"

#define SDMA_NUM (4)
#define DEV_NAME "sdma_dev"

#define VENDOR_ID 0x10EE
#define DEV_ID 0x7038

#define DESC_MAGIC 0xad4b

#define DEV_MAX_LEN (65536)

#define BAR_DMA_IDX (0)

#define PCI_DMA_L(addr) (addr & 0xffffffffUL)
#define PCI_DMA_H(addr) ((addr >> 16) >> 16)

// DMA Bar control and status registers range
#define reg_identifier(d, i) (d * 0x1000 + i * 0x100 + 0x0)
#define reg_control(d, i) (d * 0x1000 + i * 0x100 + 0x4)
#define reg_control_w1s(d, i) (d * 0x1000 + i * 0x100 + 0x8)
#define reg_control_w1c(d, i) (d * 0x1000 + i * 0x100 + 0xC)
#define reg_status(d, i) (d * 0x1000 + i * 0x100 + 0x40)
#define reg_status_rc(d, i) (d * 0x1000 + i * 0x100 + 0x44)

#define reg_first_desc_lo(d, i) (d * 0x1000 + i * 0x100 + 0x4080)
#define reg_first_desc_hi(d, i) (d * 0x1000 + i * 0x100 + 0x4084)

#define Stop_Bit (0x1 << 0)
#define Compl_Bit (0x1 << 1)
#define EOP_Bit (0x1 << 4)

struct sdma_desc
{
    u8 control;
    u8 nxj_adj;
    u16 magic;
    u32 bytes;       /* transfer length in bytes */
    u32 src_addr_lo; /* source address (low 32-bit) */
    u32 src_addr_hi; /* source address (high 32-bit) */
    u32 dst_addr_lo; /* destination address (low 32-bit) */
    u32 dst_addr_hi; /* destination address (high 32-bit) */
    u32 next_lo;     /* next desc address (low 32-bit) */
    u32 next_hi;     /* next desc address (high 32-bit) */
} __packed;


enum dma_dir
{
    HTC,
    CTH
};

struct channel
{
    void __iomem *db_vaddr;    //
    dma_addr_t db_io_addr;
    int db_size;
    int db_status;
    struct semaphore sem;
};

struct sdma_dev
{
    struct sdma_drv *psdrv;
    struct device *device;
    void __iomem *reg_vaddr; // 64位虚拟起始地址
    int index;
    struct channel ch[2]; /*0: htc, 1: cth*/
};

struct sdma_drv
{
    struct cdev cdev;
    dev_t devno;
    struct pci_dev *pdev;
    struct class *class;
    struct sdma_dev *psdev[SDMA_NUM];
};

extern bool inline is_dma_busy(struct sdma_dev *psdev, enum dma_dir d);
extern bool inline is_dma_idle(struct sdma_dev *psdev, enum dma_dir d);
extern int start_dma(struct sdma_dev *psdev, enum dma_dir d, dma_addr_t desc);
extern int stop_dma(struct sdma_dev *psdev, enum dma_dir d);
extern int get_sdma_desc_block(struct sdma_dev *psdev, int n, enum dma_dir d);
extern void put_sdma_desc_block(struct sdma_dev *psdev, enum dma_dir d, void __iomem *db_vaddr, dma_addr_t db_io_addr);
extern void fill_sdma_desc(struct sdma_desc *spdes, int bytes, u64 src, u64 dst);

#endif /* __SDMA_H__ */