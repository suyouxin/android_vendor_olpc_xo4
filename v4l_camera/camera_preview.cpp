/*
 * Copyright (C) 2012 Renesas Electronics Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @file v4l_camera/camera_preview.cpp
 * @author Guennadi Liakhovetski <g.liakhovetski@gmx.de>
 * @brief C++ camera-preview and frame-manipulation interface
 */

#define LOG_TAG "camera_preview"
#define LOG_NDEBUG 0

#include <sys/types.h>

#include <linux/videodev2.h>

#include <cutils/log.h>
#include <ui/Rect.h>
#include <ui/GraphicBufferMapper.h>

#include "camera_param.h"
#include "camera_preview.h"

#include <Converters.h>
#include <JpegCompressor.h>

namespace android {

uint8_t *camera_preview_lock(buffer_handle_t* buffer, unsigned int width, unsigned int height)
{
	uint8_t* img = NULL;
	/* Rectangle with origin at (0,0) */
	const Rect rect(width, height);
	GraphicBufferMapper& grbuffer_mapper(GraphicBufferMapper::get());

	if (grbuffer_mapper.lock(*buffer, GRALLOC_USAGE_SW_WRITE_OFTEN, rect, (void **)&img) != NO_ERROR)
		return NULL;
	return img;
}

void camera_preview_unlock(buffer_handle_t* buffer)
{
	GraphicBufferMapper& grbuffer_mapper(GraphicBufferMapper::get());
	grbuffer_mapper.unlock(*buffer);
}

/* Converts YUV color to RGB32. */
static __inline__ uint32_t
__YUVToRGB32(int y, int u, int v)
{
    /* Calculate C, D, and E values for the optimized macro. */
    y -= 16; u -= 128; v -= 128;
    RGB32_t rgb;
    rgb.r = YUV2RO(y,u,v) & 0xff;
    rgb.g = YUV2GO(y,u,v) & 0xff;
    rgb.b = YUV2BO(y,u,v) & 0xff;
    return rgb.color;
}

static void _YUV422iToRGB32(const uint8_t* Y,
                             const uint8_t* U,
                             const uint8_t* V,
                             uint32_t* rgb,
                             int width,
                             int height)
{
    for (int x = 0; x < width * height * 2; x += 4, U += 4, V += 4) {
        const uint8_t nU = *U;
        const uint8_t nV = *V;
        *rgb = __YUVToRGB32(*Y, nU, nV);
        Y += 2; rgb++;
        *rgb = __YUVToRGB32(*Y, nU, nV);
        Y += 2; rgb++;
    }
}

/* Converts YUV color to RGB565. */
static __inline__ uint16_t
__YUVToRGB565(int y, int u, int v)
{
    /* Calculate C, D, and E values for the optimized macro. */
    y -= 16; u -= 128; v -= 128;
    const uint16_t b = (YUV2RO(y,u,v) >> 3) & 0x1f;
    const uint16_t g = (YUV2GO(y,u,v) >> 2) & 0x3f;
    const uint16_t r = (YUV2BO(y,u,v) >> 3) & 0x1f;
    return RGB565(r, g, b);
}

static void _YUV422iToRGB565(const uint8_t* Y,
                             const uint8_t* U,
                             const uint8_t* V,
                             uint16_t* rgb,
                             int width,
                             int height)
{
    for (int x = 0; x < width * height * 2; x += 4, U += 4, V += 4) {
        const uint8_t nU = *U;
        const uint8_t nV = *V;
        *rgb = __YUVToRGB565(*Y, nU, nV);
        Y += 2; rgb++;
        *rgb = __YUVToRGB565(*Y, nU, nV);
        Y += 2; rgb++;
    }
}

void YUY2ToRGB565(const void* yuyv, void* rgb, int width, int height)
{
    const uint8_t* Y = reinterpret_cast<const uint8_t*>(yuyv);
    const uint8_t* U = Y + 1;
    const uint8_t* V = U + 2;
    _YUV422iToRGB565(Y, U, V, reinterpret_cast<uint16_t*>(rgb), width, height);
}

void YUY2ToRGB32(const void* yuyv, void* rgb, int width, int height)
{
    const uint8_t* Y = reinterpret_cast<const uint8_t*>(yuyv);
    const uint8_t* U = Y + 1;
    const uint8_t* V = U + 2;

    int start = 150;
    for (int i = 0; i < 20; i++) {
        int step = i * 10;
    ALOGV("DUMP: Y: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", 
            Y[step + start],
            Y[step + start + 1],
            Y[step + start + 2],
            Y[step + start + 3],
            Y[step + start + 4],
            Y[step + start + 5],
            Y[step + start + 6],
            Y[step + start + 7],
            Y[step + start + 8],
            Y[step + start + 9]
            );
    }
    _YUV422iToRGB32(Y, U, V, reinterpret_cast<uint32_t*>(rgb), width, height);
}

/* TODO: add trivial memcpy converters too */
camera_frame_converter camera_frame_converter_select(uint32_t fourcc, int fb_fmt)
{
	switch (fourcc) {
	case V4L2_PIX_FMT_YUYV:
        switch (fb_fmt) {
		case HAL_PIXEL_FORMAT_RGB_565:
            ALOGE("%s(): %d", __func__, __LINE__);
			return YUY2ToRGB565;
		case HAL_PIXEL_FORMAT_RGBA_8888:
            ALOGE("%s(): %d", __func__, __LINE__);
			return YUY2ToRGB32;
		}
		break;
	case V4L2_PIX_FMT_YVU420:
		switch (fb_fmt) {
		case HAL_PIXEL_FORMAT_RGB_565:
			return YV12ToRGB565;
		case HAL_PIXEL_FORMAT_RGBA_8888:
			return YV12ToRGB32;
//		case HAL_PIXEL_FORMAT_RGB_888:
//		case HAL_PIXEL_FORMAT_RGBA_5551:
		}
		break;
	case V4L2_PIX_FMT_YUV420:
		switch (fb_fmt) {
		case HAL_PIXEL_FORMAT_RGBA_8888:
			return YU12ToRGB32;
		}
		break;
	case V4L2_PIX_FMT_NV21:
		switch (fb_fmt) {
		case HAL_PIXEL_FORMAT_RGB_565:
			return NV21ToRGB565;
		case HAL_PIXEL_FORMAT_RGBA_8888:
			return NV21ToRGB32;
		}
		break;
	case V4L2_PIX_FMT_NV12:
		switch (fb_fmt) {
		case HAL_PIXEL_FORMAT_RGB_565:
			return NV12ToRGB565;
		case HAL_PIXEL_FORMAT_RGBA_8888:
			return NV12ToRGB32;
		}
	}
	ALOGE("%s(): %x -> %x conversion unsupported", __func__, fourcc, fb_fmt);
	return NULL;
}

int camera_frame_compress(struct camera_callback *cb, uint8_t *in,
			  unsigned int width, unsigned int height)
{
	ALOGE("%s(): buffer address: %p, width:%d, height:%d", __func__, in, width, height);
	YUYVJpegCompressor compressor;
	status_t ret = compressor.compressRawImage(in, width, height, 90);

	if (ret == NO_ERROR) {
		camera_memory_t* jpeg_buff =
			cb->get_mem(-1, compressor.getCompressedSize(), 1, NULL);
		if (jpeg_buff && jpeg_buff->data) {
			compressor.getCompressedImage(jpeg_buff->data);
			cb->data(CAMERA_MSG_COMPRESSED_IMAGE, jpeg_buff, 0, NULL, cb->arg);
			jpeg_buff->release(jpeg_buff);
		} else {
			ALOGE("%s(): memory allocation failure", __func__);
			return -ENOMEM;
		}
	} else {
		ALOGE("%s(): compression failure", __func__);
		return -ENODATA;
	}
	return 0;
}

};
