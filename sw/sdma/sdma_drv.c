#include <linux/uio.h>
#include <linux/fs.h>
#include <linux/module.h>

#include "sdma.h"

static int sdma_dev_open(struct inode *inode, struct file *fp)
{

    struct sdma_drv *psdrv = (struct sdma_drv *)(inode->i_cdev);
    dev_t devno = MKDEV(imajor(inode), iminor(inode));
    int index = devno - psdrv->devno;
    struct sdma_dev *psdev = psdrv->psdev[index];

    fp->private_data = (void *)psdev;

    return 0;
}

static int sdma_dev_release(struct inode *ind, struct file *fp)
{

    fp->private_data = NULL;

    return 0;
}

static ssize_t sdma_dev_read(struct file *fp, char __user *buf, size_t size, loff_t *pos)
{

    int rc;
    struct sdma_dev *psdev = (struct sdma_dev *)fp->private_data;
    void __iomem *kmem_vaddr;
    dma_addr_t kmem_io_addr;

    if (*pos + size > DEV_MAX_LEN)
    {
        size = DEV_MAX_LEN - *pos;
    }

    if (get_sdma_desc_block(psdev, 1, CTH))
    {
        pr_err("Fail to get sdma desc block\n");
        return -EFAULT;
    }

    // create kernel buffer
    kmem_vaddr = dma_alloc_coherent(&psdev->psdrv->pdev->dev, size, &kmem_io_addr, GFP_KERNEL);
    if (!kmem_vaddr)
    {
        pr_err("OOM: allocate sdev kmem\n");
        return -EBUSY;
    }

    fill_sdma_desc((struct sdma_desc *)(psdev->ch[CTH].db_vaddr), size, *pos, kmem_io_addr);

    start_dma(psdev, CTH, psdev->ch[CTH].db_io_addr);

    if (!is_dma_idle(psdev, CTH))
    {
        pr_err("DMA is always busy\n");
        return -EFAULT;
    }

    stop_dma(psdev, CTH);

    put_sdma_desc_block(psdev, CTH, psdev->ch[CTH].db_vaddr, psdev->ch[CTH].db_io_addr);

    rc = copy_to_user(buf, kmem_vaddr, size);
    if (rc < 0)
    {
        pr_err("copy_to_user failed!");
        return -EFAULT;
    }

    *pos += size;

    return size;
}

static ssize_t sdma_dev_write(struct file *fp, const char __user *buf, size_t size, loff_t *pos)
{
    int rc;
    struct sdma_dev *psdev;
    void __iomem *kmem_vaddr;
    dma_addr_t kmem_io_addr;

    if (*pos + size > DEV_MAX_LEN)
    {
        size = DEV_MAX_LEN - *pos;
    }

    psdev = (struct sdma_dev *)fp->private_data;

    // create kernel buffer
    kmem_vaddr = dma_alloc_coherent(&psdev->psdrv->pdev->dev, size, &kmem_io_addr, GFP_KERNEL);
    if (!kmem_vaddr)
    {
        pr_err("OOM: allocate sdev kmem\n");
        return -EBUSY;
    }

    rc = copy_from_user(kmem_vaddr, buf, size);
    if (rc < 0)
    {
        pr_err("copy_to_user failed!");
        return -EFAULT;
    }

    if (get_sdma_desc_block(psdev, 1, HTC))
    {
        pr_err("Fail to get sdma desc block\n");
        return -EFAULT;
    }

    fill_sdma_desc((struct sdma_desc *)(psdev->ch[HTC].db_vaddr), size, kmem_io_addr, *pos);

    start_dma(psdev, HTC, psdev->ch[HTC].db_io_addr);

    if (!is_dma_idle(psdev, HTC))
    {
        pr_err("DMA is always busy\n");
        return -EFAULT;
    }

    stop_dma(psdev, HTC);

    put_sdma_desc_block(psdev, HTC, psdev->ch[HTC].db_vaddr, psdev->ch[HTC].db_io_addr);

    *pos += size;

    return size;
}

ssize_t sdma_dev_read_iter(struct kiocb *cb, struct iov_iter *iter)
{
    int rc;
    struct sdma_dev *psdev;
    void __iomem *kmem_vaddr;
    dma_addr_t kmem_io_addr;

    loff_t offset;
    ssize_t size;

    offset = cb->ki_pos;
    size = iov_iter_count(iter);

    if (offset + size > DEV_MAX_LEN)
    {
        size = DEV_MAX_LEN - offset;
    }

    psdev = (struct sdma_dev*) cb->ki_filp->private_data;

    // create kmem
    kmem_vaddr = dma_alloc_coherent(&psdev->psdrv->pdev->dev, size, &kmem_io_addr, GFP_KERNEL);
    if (!kmem_vaddr) {
		pr_err("OOM: allocate sdma_desc\n");
		return -EBUSY;
	}

    if (get_sdma_desc_block(psdev, 1, CTH))
    {
        pr_err("Fail to get sdma desc block\n");
        return -EFAULT;
    }

    fill_sdma_desc((struct sdma_desc *)(psdev->ch[CTH].db_vaddr), size, offset, kmem_io_addr);

    start_dma(psdev, CTH, psdev->ch[CTH].db_io_addr);

    if (!is_dma_idle(psdev, CTH))
    {
        pr_err("DMA is always busy\n");
        return -EFAULT;
    }

    stop_dma(psdev, CTH);

    put_sdma_desc_block(psdev, CTH, psdev->ch[CTH].db_vaddr, psdev->ch[CTH].db_io_addr);


        // copy to user
    ssize_t total_read = 0;
    ssize_t cnt = 0;
    
    while (iov_iter_count(iter)) {
        size_t bytes = iter->iov->iov_len;
        pr_info("count=%d, bytes=%d, %s\n", iov_iter_count(iter), bytes, (char *)iter->iov->iov_base);
        bytes = copy_to_iter(kmem_vaddr + total_read, bytes, iter);
        total_read += bytes;
    }
    cb->ki_pos += size;

    pr_info("kmem: %d %d %s\n", total_read, size, kmem_vaddr);

    return size;
}

ssize_t sdma_dev_write_iter(struct kiocb *cb, struct iov_iter *iter)
{
    int rc;
    struct sdma_dev *psdev;
    void __iomem *kmem_vaddr;
    dma_addr_t kmem_io_addr;

    loff_t offset;
    ssize_t size;

    offset = cb->ki_pos;
    size = iov_iter_count(iter);

    if (offset + size > DEV_MAX_LEN)
    {
        size = DEV_MAX_LEN - offset;
    }

    psdev = (struct sdma_dev*) cb->ki_filp->private_data;

    // create kmem
    kmem_vaddr = dma_alloc_coherent(&psdev->psdrv->pdev->dev, size, &kmem_io_addr, GFP_KERNEL);
    if (!kmem_vaddr) {
		pr_err("OOM: allocate sdma_desc\n");
		return -EBUSY;
	}

    // copy from user
    ssize_t total_written = 0;
    ssize_t cnt = 0;
    
    while (iov_iter_count(iter)) {
        size_t bytes = iter->iov->iov_len;
        pr_info("count=%d, bytes=%d, %s\n", iov_iter_count(iter), bytes, (char *)iter->iov->iov_base);
        bytes = copy_from_iter(kmem_vaddr + total_written, bytes, iter);
        total_written += bytes;
    }

    pr_info("kmem: %d %d %s\n", total_written, size, kmem_vaddr+6);

    if (get_sdma_desc_block(psdev, 1, HTC))
    {
        pr_err("Fail to get sdma desc block\n");
        return -EFAULT;
    }

    fill_sdma_desc((struct sdma_desc *)(psdev->ch[HTC].db_vaddr), size, kmem_io_addr, offset);

    start_dma(psdev, HTC, psdev->ch[HTC].db_io_addr);

    if (!is_dma_idle(psdev, HTC))
    {
        pr_err("DMA is always busy\n");
        return -EFAULT;
    }

    stop_dma(psdev, HTC);

    put_sdma_desc_block(psdev, HTC, psdev->ch[HTC].db_vaddr, psdev->ch[HTC].db_io_addr);

    cb->ki_pos += size;

    return size;
}

loff_t sdma_dev_llseek(struct file *filp, loff_t offset, int whence)
{
    loff_t new_pos;
    struct sdma_drv *psdrv = filp->private_data;

    if (!psdrv)
    {
        return -EBADF;
    }

    switch (whence)
    {
    case SEEK_SET:
        new_pos = offset;
        break;
    case SEEK_CUR:
        new_pos = filp->f_pos + offset;
        break;
    case SEEK_END:
        new_pos = DEV_MAX_LEN + offset;
        break;
    default:
        return -EINVAL;
    }

    if (new_pos < 0 || new_pos > DEV_MAX_LEN)
    {
        return -EINVAL;
    }

    filp->f_pos = new_pos;

    return new_pos;
}

static struct file_operations my_fops = {
    .owner = THIS_MODULE,
    .open = sdma_dev_open,
    .release = sdma_dev_release,
    .read = sdma_dev_read,
    .write = sdma_dev_write,
    .read_iter = sdma_dev_read_iter,
    .write_iter = sdma_dev_write_iter,
    .llseek = sdma_dev_llseek};

static int my_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
    int i, j;
    int res;

    struct sdma_drv *psdrv;
    struct cdev *pcdev;

    void __iomem *reg_vaddr; // 64位虚拟起始地址

    if (pci_enable_device(pdev))
    {
        res = -EINVAL;
        goto fail0;
    }

    if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)))
    {
        res = -EINVAL;
        goto fail1;
    }

    pci_set_master(pdev);

    psdrv = (struct sdma_drv *)kmalloc(sizeof(struct sdma_drv) + SDMA_NUM * sizeof(struct sdma_dev), GFP_KERNEL | __GFP_ZERO);
    if (psdrv == NULL)
    {
        res = -EFAULT;
        goto fail1;
    }

    psdrv->psdev[0] = (struct sdma_dev *)(psdrv + 1);

    for (i = 1; i < SDMA_NUM; i++)
    {
        psdrv->psdev[i] = (struct sdma_dev *)(psdrv->psdev[i - 1] + 1);
    }

    pcdev = (struct cdev *)psdrv;
    cdev_init(pcdev, &my_fops);

    res = alloc_chrdev_region(&psdrv->devno, 0, SDMA_NUM, DRIVER_NAME);

    if (res < 0)
    {
        pr_err("alloc_chrdev_region failed!");
        res = -EFAULT;
        goto fail2;
    }

    res = cdev_add(pcdev, psdrv->devno, SDMA_NUM);

    if (res < 0)
    {
        pr_err("cdev_add failed!");
        res = -EFAULT;
        goto fail3;
    }

    /* 设备模型相关需求 */
    psdrv->class = class_create(THIS_MODULE, CLASS_NAME);
    if (psdrv->class == NULL)
    {
        res = -EFAULT;
        goto fail4;
    }

    reg_vaddr = pci_iomap(pdev, BAR_DMA_IDX,
                          pci_resource_len(pdev, BAR_DMA_IDX));

    if (reg_vaddr == NULL)
    {
        res = -EFAULT;
        goto fail5;
    }

    for (i = 0; i < SDMA_NUM; i++)
    {
        sema_init(&(psdrv->psdev[i]->ch[0].sem), 1);
        sema_init(&(psdrv->psdev[i]->ch[1].sem), 1);
        psdrv->psdev[i]->index = i;
        psdrv->psdev[i]->psdrv = psdrv;
        psdrv->psdev[i]->reg_vaddr = reg_vaddr;
        stop_dma(psdrv->psdev[i], 0);
        stop_dma(psdrv->psdev[i], 1);
    }

    for (i = 0; i < SDMA_NUM; i++)
    {
        psdrv->psdev[i]->device = device_create(psdrv->class, NULL,
                                                MKDEV(MAJOR(psdrv->devno), MINOR(psdrv->devno) + i),
                                                NULL, "%s%d", DEV_NAME, MINOR(psdrv->devno) + i);
        if (psdrv->psdev[i]->device == NULL)
        {
            res = -EFAULT;
            goto fail6;
        }
    }

    psdrv->pdev = pdev;
    pci_set_drvdata(pdev, psdrv);

    return 0;

// pci_iounmap(pdev, psd->vaddr);  //可以删除，但最好注释在这里
fail6:
{
    for (j = i - 1; j >= 0; j--)
    {
        device_destroy(psdrv->class, MKDEV(MAJOR(psdrv->devno), MINOR(psdrv->devno) + j));
    }
}
fail5:
    class_destroy(psdrv->class);
fail4:
    cdev_del(&psdrv->cdev);
fail3:
    unregister_chrdev_region(psdrv->devno, SDMA_NUM);
fail2:
    kfree(psdrv);
fail1:
    pci_disable_device(pdev);
fail0:
    return res;
}

static void my_pci_remove(struct pci_dev *pdev)
{
    int i;
    struct sdma_drv *psdrv;
    psdrv = pci_get_drvdata(pdev);

    pci_iounmap(pdev, psdrv->psdev[0]->reg_vaddr);

    for (i = 0; i < SDMA_NUM; i++)
    {
        device_destroy(psdrv->class, MKDEV(MAJOR(psdrv->devno), MINOR(psdrv->devno) + i));
    }
    class_destroy(psdrv->class);
    cdev_del(&psdrv->cdev);
    unregister_chrdev_region(psdrv->devno, SDMA_NUM);
    kfree(psdrv);
    pci_disable_device(pdev);
    return;
}

static const struct pci_device_id my_pci_ids[] = {
    {PCI_DEVICE(VENDOR_ID, DEV_ID)},
    {
        0,
    }};

static struct pci_driver my_pcidrv = {
    .name = DRIVER_NAME,
    .probe = my_pci_probe,
    .remove = my_pci_remove,
    .id_table = my_pci_ids};

static int my_drvinit(void)
{
    return pci_register_driver(&my_pcidrv);
}

static void my_drvexit(void)
{
    pci_unregister_driver(&my_pcidrv);
}

module_init(my_drvinit);
module_exit(my_drvexit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Amaris");
MODULE_DESCRIPTION("Adapt xilinx xdma ip");
MODULE_VERSION("1.0");
MODULE_LICENSE("Dual BSD/GPL");