#ifndef __INCLINOMETERDEMO_H__
#define __INCLINOMETERDEMO_H__


enum {
    AM_ACCELMSG = 6,
};

//#define MAX_BUFFER_SIZE 256
#define MAX_BUFFER_SIZE 16

typedef nx_struct AccelMsg{
    nx_int16_t x;
}AccelMsg;


#endif /* end of include guard: __INCLINOMETERDEMO_H__ */
