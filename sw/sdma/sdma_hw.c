#include <linux/delay.h> 

#include "sdma.h"

void inline write32_register(struct sdma_dev *psdev, u32 value, u32 offset)
{
    iowrite32(value, (char *)(psdev->reg_vaddr) + offset);
}

u32 inline read32_register(struct sdma_dev *psdev, u32 offset)
{
    return ioread32((char *)(psdev->reg_vaddr) + offset);
}

bool inline is_dma_busy(struct sdma_dev *psdev, enum dma_dir d)
{
    return !!(0x1 & read32_register(psdev, reg_status(d, psdev->index)));
}

bool inline is_dma_idle(struct sdma_dev *psdev, enum dma_dir d)
{
    int cnt = 0;
    while (is_dma_busy(psdev, d))
    {
        udelay(100);
        cnt++;
        if (cnt > 1000)
            return false;
    }

    return true;
}

int start_dma(struct sdma_dev *psdev, enum dma_dir d, dma_addr_t desc)
{
    wmb();

    if (!is_dma_idle(psdev, d))
        return -EFAULT;

    write32_register(psdev, cpu_to_le32(PCI_DMA_L(desc)), reg_first_desc_lo(d, psdev->index));

    write32_register(psdev, cpu_to_le32(PCI_DMA_H(desc)), reg_first_desc_hi(d, psdev->index));

    wmb();
    write32_register(psdev, 0x1, reg_control_w1s(d, psdev->index));

    return 0;
}

int stop_dma(struct sdma_dev *psdev, enum dma_dir d)
{
    write32_register(psdev, 0x1, reg_control_w1c(d, psdev->index));

    wmb();
    if (!is_dma_idle(psdev, d))
        return -EFAULT;

    return 0;
}

int get_sdma_desc_block(struct sdma_dev *psdev, int n, enum dma_dir d)
{
    int res = 0;
    void __iomem *db_vaddr;
    dma_addr_t db_io_addr;
    struct sdma_desc *psdes, *pt;

    int i;

    down_interruptible(&psdev->ch[d].sem);

    db_vaddr = dma_alloc_coherent(&psdev->psdrv->pdev->dev, n * sizeof(struct sdma_desc), &db_io_addr, GFP_KERNEL);
    if (!db_vaddr)
    {
        res = -EFAULT;
        goto fail;
    }

    psdev->ch[d].db_vaddr = db_vaddr;
    psdev->ch[d].db_io_addr = db_io_addr;
    psdev->ch[d].db_size = n;

    psdev->ch[d].db_status = 1;

    psdes = (struct sdma_desc *)db_vaddr;
    pt = (struct sdma_desc *)db_io_addr;

    for (i = 0; i < n; i++)
    {
        dma_addr_t desc_next = (dma_addr_t)(pt + i + 1);
        psdes[i].control = 0;
        psdes[i].nxj_adj = (n - i - 2) > 0 ? (n - i - 2) : 0;
        psdes[i].magic = cpu_to_le16(DESC_MAGIC);
        psdes[i].next_lo = cpu_to_le32(PCI_DMA_L(desc_next));
        psdes[i].next_hi = cpu_to_le32(PCI_DMA_H(desc_next));
    }
    psdes[n - 1].next_lo = 0;
    psdes[n - 1].next_hi = 0;
    psdes[n - 1].control = 0x1; // end of desc block

fail:
    return res;
}

void put_sdma_desc_block(struct sdma_dev *psdev, enum dma_dir d, void __iomem *db_vaddr, dma_addr_t db_io_addr)
{
    dma_free_coherent(&psdev->psdrv->pdev->dev, psdev->ch[d].db_size * sizeof(struct sdma_desc), db_vaddr, db_io_addr);
    psdev->ch[d].db_status = 0;
    up(&(psdev->ch[d].sem));
}

void fill_sdma_desc(struct sdma_desc *spdes, int bytes, u64 src, u64 dst)
{
    spdes->bytes = cpu_to_le32(bytes);
    spdes->src_addr_lo = cpu_to_le32(src);
    spdes->src_addr_hi = cpu_to_le32(src >> 32);
    spdes->dst_addr_lo = cpu_to_le32(dst);
    spdes->dst_addr_hi = cpu_to_le32(dst >> 32);
}