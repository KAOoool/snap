#ifndef  __CONFIG_H_
#define  __CONFIG_H_

#define f_416x240               1
#define DB_OPEN
#define MAXBUFFSIZE 500000

#ifdef QCIF
#define FRAMEWIDTH  192 // #define FRAMEWIDTH  176
#define FRAMEHEIGHT 192 // #define FRAMEHEIGHT 144
#elif CIF
#define FRAMEWIDTH  384 // #define FRAMEWIDTH  352
#define FRAMEHEIGHT 384 // #define FRAMEHEIGHT 288
#elif D1
#define FRAMEWIDTH  768 // #define FRAMEWIDTH  720
#define FRAMEHEIGHT 576 // #define FRAMEHEIGHT 576
#elif p720
#define FRAMEWIDTH  1280 // #define FRAMEWIDTH 1280
#define FRAMEHEIGHT 768  // #define FRAMEHEIGHT 720
#elif p1080
#define FRAMEWIDTH  1920 // #define FRAMEWIDTH  1920
#define FRAMEHEIGHT 1088 // #define FRAMEHEIGHT 1080
#elif f_416x240
#define FRAMEWIDTH  448 // #define FRAMEWIDTH  416
#define FRAMEHEIGHT 256 // #define FRAMEHEIGHT 240
#elif f_832x480
#define FRAMEWIDTH  832 // #define FRAMEWIDTH  832
#define FRAMEHEIGHT 512 // #define FRAMEHEIGHT 480
#elif f_1024x768
#define FRAMEWIDTH 1024 // #define FRAMEWIDTH 1024
#define FRAMEHEIGHT 768 // #define FRAMEHEIGHT 768
#elif f_2560x1600
#define FRAMEWIDTH 2560
#define FRAMEHEIGHT 1600
#endif

#define f_LCU_SIZE              64
#define GOP_LENGTH              1
#define FRAME_TOTAL             1
#define QP                      0x00000016
#define X_TOTAL                 (FRAMEWIDTH /64)-1
#define Y_TOTAL                 (FRAMEHEIGHT /64)-1
#define MEM_SIZE                FRAMEWIDTH*FRAMEHEIGHT*3/2
#define REC_0_BASE              (FRAMEWIDTH*FRAMEHEIGHT*3/2)*1 
#define REC_1_BASE              (FRAMEWIDTH*FRAMEHEIGHT*3/2)*2

#endif

