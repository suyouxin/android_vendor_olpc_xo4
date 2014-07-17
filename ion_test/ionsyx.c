#define LOG_TAG "iontest"
#define DDEBUG 0

#include <limits.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/ioctl.h>

#include <cutils/ashmem.h>
#include <cutils/log.h>
#include <cutils/atomic.h>

#include <linux/ion.h>
#include <linux/pxa_ion.h>
#include "../ion/ion.h"

#define _ALIGN( n, align_dst ) ( (n + (align_dst-1)) & ~(align_dst-1) )

static int ion_alloc_buffer(int offset, int size, int *o_fd, int *physaddr)
{
    struct ion_allocation_data req_alloc;
    struct ion_fd_data req_fd;
    struct ion_handle *handle;
    struct ion_custom_data data;
    struct ion_pxa_region region;
    int fd, ret, shared_fd;

    ALOGE("trace line %s:%d", __FILE__, __LINE__);
    fd = open("/dev/ion", O_RDWR, 0);
    if (fd < 0) {
        ALOGE("Failed to open /dev/ion");
        return fd;
    }
    ALOGE("trace line %s:%d", __FILE__, __LINE__);
    memset(&req_alloc, 0, sizeof(struct ion_allocation_data));
    req_alloc.len = _ALIGN(size, PAGE_SIZE);
    req_alloc.align = PAGE_SIZE;
    req_alloc.heap_id_mask = ION_HEAP_TYPE_DMA_MASK;
    req_alloc.flags = ION_FLAG_CACHED | ION_FLAG_CACHED_NEEDS_SYNC;
    ret = ioctl(fd, ION_IOC_ALLOC, &req_alloc);
    ALOGE("trace line %s:%d", __FILE__, __LINE__);
    if (ret < 0){
        ALOGE("Failed to ION_IOC_ALLOC. if ret is -ENODEV means ION size is not enough,ret:%d",ret);
        ret = -errno;
        goto out;
    }
    handle = req_alloc.handle;

    ALOGE("trace line %s:%d", __FILE__, __LINE__);
    memset(&region, 0, sizeof(struct ion_pxa_region));
    memset(&data, 0, sizeof(struct ion_custom_data));
    region.handle = handle;
    data.cmd = ION_PXA_PHYS;
    data.arg = (unsigned long)&region;
    ret = ioctl(fd, ION_IOC_CUSTOM, &data);
    if (ret < 0) {
        ret = -errno;
        goto out;
    }
    ALOGE("trace line %s:%d", __FILE__, __LINE__);
    *physaddr = region.addr;
    memset(&req_fd, 0, sizeof(struct ion_fd_data));
    req_fd.handle = handle;
    ret = ioctl(fd, ION_IOC_SHARE, &req_fd);
    if (ret < 0) {
        ret = -errno;
        goto out;
    }
    ALOGE("trace line %s:%d", __FILE__, __LINE__);
    *o_fd = fd;
    return req_fd.fd;
out:
    close(fd);
    ALOGE("Failed to allocate memory from ION");
    return ret;
}
int main(int argc, char **argv) {
    /* int fd; */
    /* fd = ion_open(); */
    /* if (fd < 0) { */
        /* ALOGE("open /dev/ion failed!\n"); */
        /* return -1; */
    /* } */
    int fd, address;
    ion_alloc_buffer(0, 1024*1024, &fd, &address);

    /* ion_close(fd); */
    return 0;
}
