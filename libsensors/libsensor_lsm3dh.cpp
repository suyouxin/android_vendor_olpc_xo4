// #define LOG_NDEBUG 0
#define LOG_TAG "Sensors"
#define FUNC_LOG

#include <hardware/sensors.h>
#include <fcntl.h>
#include <errno.h>
#include <dirent.h>
#include <math.h>
#include <poll.h>
#include <pthread.h>
#include <stdlib.h>

#include <linux/input.h>

#include <utils/Atomic.h>
#include <utils/Log.h>

/** SENSOR IDS AND NAMES
 **/

#define MAX_NUM_SENSORS 1

#define SUPPORTED_SENSORS  ((1<<MAX_NUM_SENSORS)-1)

#define  ID_BASE           SENSORS_HANDLE_BASE
#define  ID_ACCELERATION   (ID_BASE+0)

#define  SENSORS_ACCELERATION   (1 << ID_ACCELERATION)

static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

static struct sensor_t sSensorList[MAX_NUM_SENSORS] = {

      {   "LSM303DLH 3-axis Accelerometer",
          "STMicroelectronics",
          1, 
          ID_ACCELERATION,
          SENSOR_TYPE_ACCELEROMETER, 
          GRAVITY_EARTH * 4.0f, 
          GRAVITY_EARTH * 4.0f / 4000.0f, 
          0.25f, 
          1,
		  0,
		  8,
          SENSOR_STRING_TYPE_ACCELEROMETER,
		  "",
		  100,
		  SENSOR_FLAG_CONTINUOUS_MODE,
          { } 
      },
};
 
static int sensors__get_sensors_list(struct sensors_module_t* module,
                                     struct sensor_t const** list)
{
    *list = sSensorList;
    return MAX_NUM_SENSORS;
}

static int open_sensors(const struct hw_module_t* module, const char* id,
                        struct hw_device_t** device);
static struct hw_module_methods_t sensors_module_methods = {
        open: open_sensors
};

struct sensors_module_t HAL_MODULE_INFO_SYM = {
        common: {
                tag: HARDWARE_MODULE_TAG,
                version_major: 1,
                version_minor: 0,
                id: SENSORS_HARDWARE_MODULE_ID,
                name: "LSM3DH Sensor module",
                author: "Morphoss Company",
                methods: &sensors_module_methods,
                dso: 0,
                reserved: {},
        },
        get_sensors_list: sensors__get_sensors_list,
};

typedef struct acc_raw_data
{
  signed short ax;  //x value
  signed short ay;  //y value
  signed short az;  //z value
  signed long time; //system time
} acc_raw_data;

typedef struct sensors_poll_context_t {
    sensors_poll_device_t device;
	int acc_event_fd;
    acc_raw_data raw_data;
    sensors_event_t sensors[MAX_NUM_SENSORS];
	uint32_t pendingSensors;
} sensors_poll_context_t;

static int poll_close(struct hw_device_t *dev)
{
    FUNC_LOG;
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    if (ctx) {
		if (ctx->acc_event_fd > 0){
			close(ctx->acc_event_fd);
			ctx->acc_event_fd = -1;
		}
        delete ctx;
    }
    return 0;
}

static int poll_activate(struct sensors_poll_device_t *dev,
                          int handle, int enabled)
{
    // FUNC_LOG;
    // sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    // return ctx->activate(handle, enabled);
	// int acc_event;
	// acc_event = open("/dev/input/event0", O_RDWR);
	// if (acc_event < 0)
		// return -1;
	// else {
        // acc_event_fd = acc_event;
        // return 0;
	// }
    return 0;
}

static int poll_setDelay(struct sensors_poll_device_t *dev,
                          int handle, int64_t ns)
{
    // FUNC_LOG;
    // sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    // return ctx->setDelay(handle, ns);
    return 0;
}

/* return the current time in nanoseconds */
static int64_t data__now_ns(void)
{
    struct timespec  ts;

    clock_gettime(CLOCK_MONOTONIC, &ts);

    return (int64_t)ts.tv_sec * 1000000000 + ts.tv_nsec;
}

static int get_events_val(sensors_poll_context_t *ctx, acc_raw_data *data)
{
	struct input_event acc_event;
	int ret;

	while(1) {
		ret = read(ctx->acc_event_fd, &acc_event, sizeof(struct input_event));
		if (ret != sizeof(struct input_event))
			continue;

		if(acc_event.type == EV_ABS) {
			if(acc_event.code == ABS_X)
				data->ax = acc_event.value; 
			if(acc_event.code == ABS_Y)
				data->ay = acc_event.value;   
			if(acc_event.code == ABS_Z)
				data->az = acc_event.value;  
		}

		if(acc_event.type == 0)
			break;
	}
	data->time = data__now_ns();
	// ALOGD("%s %d %d %d %lu\n", __FUNCTION__, data->ax, data->ay, data->az, data->time);
	return 0;
}

static int poll_poll(struct sensors_poll_device_t *dev,
                      sensors_event_t* data, int count)
{
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    if (count < 1 || count < MAX_NUM_SENSORS)
        return -EINVAL;

    if (ctx->acc_event_fd < 0) {
        ALOGE("HAL:missed accel events, exit");
        return -EINVAL;
    }

	pthread_mutex_lock(&g_lock);

    int i = 0;
    do {
        get_events_val(ctx, &ctx->raw_data); 

        data[i].version = sizeof(sensors_event_t);
        data[i].type = SENSOR_TYPE_ACCELEROMETER; 
        data[i].sensor = ID_ACCELERATION;
        data[i].acceleration.y = ctx->raw_data.ay * GRAVITY_EARTH / 1000.0f;  
        data[i].acceleration.x = - ctx->raw_data.ax * GRAVITY_EARTH / 1000.0f;  
        data[i].acceleration.z = - ctx->raw_data.az * GRAVITY_EARTH / 1000.0f;  
        data[i].timestamp = ctx->raw_data.time;  

        // ALOGD("%s: %d [%f, %f, %f]", __FUNCTION__,
            // data->sensor,
            // data->acceleration.x,
            // data->acceleration.y,
            // data->acceleration.z
        // );
        i++;
    } while((count - i) > 0);

    pthread_mutex_unlock(&g_lock);
	return i;
}

/** Open a new instance of a sensor device using name */
static int open_sensors(const struct hw_module_t* module, const char* id,
                        struct hw_device_t** device)
{
    FUNC_LOG;
    int status = -EINVAL;

    ALOGD("SENSORS: %d\n", __LINE__);
    if (strcmp(id, SENSORS_HARDWARE_POLL) == 0) {
        sensors_poll_context_t *dev = new sensors_poll_context_t();

        memset(&dev->device, 0, sizeof(sensors_poll_device_t));
        memset(&dev->sensors, 0, sizeof(dev->sensors));
        memset(&dev->raw_data, 0, sizeof(dev->raw_data));

        dev->device.common.tag = HARDWARE_DEVICE_TAG;
        dev->device.common.version  = 0;
        dev->device.common.module   = const_cast<hw_module_t*>(module);
        dev->device.common.close    = poll_close;
        dev->device.activate        = poll_activate;
        dev->device.setDelay        = poll_setDelay;
        dev->device.poll            = poll_poll;

        *device = &dev->device.common;
        status = 0;
        dev->pendingSensors = 0;
        dev->acc_event_fd = -1;
        dev->acc_event_fd = open("/dev/input/event0", O_RDWR);
        ALOGD("open acc fd, return %d\n", dev->acc_event_fd);

        pthread_mutex_init(&g_lock, NULL);
    }

    return status;
}

