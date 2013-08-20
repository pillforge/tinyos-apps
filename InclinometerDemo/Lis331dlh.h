#ifndef __LIS331DLH_H__
#define __LIS331DLH_H__

typedef nx_struct accel_t {
  nx_int16_t x;
  nx_int16_t y;
  nx_int16_t z;
} accel_t;

#define LIS331DLH_WHO_I_AM   0x8F
#define LIS331DLH_CTRL1      0x20
#define LIS331DLH_CTRL1_SET  0x2F


#define LIS331DLH_ACK   0x32

#define LIS331DLH_AXl   0xA8
#define LIS331DLH_AXh   0xA9
#define LIS331DLH_AYl   0xAA
#define LIS331DLH_AYh   0xAB
#define LIS331DLH_AZl   0xAC
#define LIS331DLH_AZh   0xAD

#endif /* end of include guard: __LIS331DLH_H__ */
