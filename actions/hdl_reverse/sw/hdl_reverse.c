/*
 * Copyright 2017 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	 http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <malloc.h>
#include <unistd.h>
#include <sys/time.h>
#include <time.h>
#include <getopt.h>
#include <ctype.h>

#include <libsnap.h>
#include <snap_tools.h>
#include <snap_s_regs.h>

#include "hdl_reverse.h"

/*  defaults */
#define ACTION_WAIT_TIME	10   /* Default in sec */

#define MEGAB	   (1024*1024ull)
#define GIGAB	   (1024 * MEGAB)

#define VERBOSE0(fmt, ...) do {		 \
		printf(fmt, ## __VA_ARGS__);	\
	} while (0)

#define VERBOSE1(fmt, ...) do {		 \
		if (verbose_level > 0)		  \
			printf(fmt, ## __VA_ARGS__);	\
	} while (0)

#define VERBOSE2(fmt, ...) do {		 \
		if (verbose_level > 1)		  \
			printf(fmt, ## __VA_ARGS__);	\
	} while (0)


#define VERBOSE3(fmt, ...) do {		 \
		if (verbose_level > 2)		  \
			printf(fmt, ## __VA_ARGS__);	\
	} while (0)

#define VERBOSE4(fmt, ...) do {		 \
		if (verbose_level > 3)		  \
			printf(fmt, ## __VA_ARGS__);	\
	} while (0)

static const char* version = GIT_VERSION;
static  int verbose_level = 0;

static uint64_t get_usec (void)
{
	struct timeval t;

	gettimeofday (&t, NULL);
	return t.tv_sec * 1000000 + t.tv_usec;
}


static void* alloc_mem (int align, int size)
{
	void* a;
	int size2 = size + align;

	VERBOSE2 ("%s Enter Align: %d Size: %d\n", __func__, align, size);

	if (posix_memalign ((void**)&a, 4096, size2) != 0) {
		perror ("FAILED: posix_memalign()");
		return NULL;
	}

	VERBOSE2 ("%s Exit %p\n", __func__, a);
	return a;
}

static int mem_init (void* src, void* dest, size_t size)
{
	uint8_t* ptr_src = (uint8_t*) src;
	uint8_t* ptr_dest = (uint8_t*) dest;
	size_t cnt;

	for (cnt = 0; cnt< size; cnt++){
		*(ptr_src++) = 0;
		*(ptr_dest++) = 0;
	}
	return 0;
}
static void free_mem (void* a)
{
	VERBOSE2 ("Free Mem %p\n", a);

	if (a) {
		free (a);
	}
}


/* Action or Kernel Write and Read are 32 bit MMIO */
static void action_write (struct snap_card* h, uint32_t addr, uint32_t data)
{
	int rc;

	rc = snap_mmio_write32 (h, (uint64_t)addr, data);

	if (0 != rc) {
		VERBOSE0 ("Write MMIO 32 Err\n");
	}

	return;
}

static uint32_t action_read(struct snap_card* h, uint32_t addr)
{
	int rc;
	uint32_t data;

	rc = snap_mmio_read32(h, (uint64_t)addr, &data);
	if (0 != rc)
		VERBOSE0("Read MMIO 32 Err\n");
	return data;
}


/*
 *  Start Action and wait for Idle.
 */

/*...*/

static int do_action (struct snap_card* dnc,
					void* src,
					void* dest,
					uint64_t* elapsed
                    )
{
	int rc = 0;
	uint64_t t_start;   /* time in usec */
	uint64_t td = 0;    /* Diff time in usec */
	
	FILE* fp_src;
	FILE* fp_des;

	uint64_t addr;
	uint32_t reg_len = 1024;
	int bs_write;
	int Byte_read;

	if ((fp_src = fopen("/home/twyang/snap/actions/hdl_reverse/sw/fetch_i_cur.yuv","rb"))==NULL) {
		VERBOSE0("ERROR: Fail to open yuv source file!\n");
		return -1;
	}
	if ((fp_des = fopen("/home/twyang/snap/actions/hdl_reverse/sw/bs.dat","ab+"))==NULL) {
		VERBOSE0("ERROR: Fail to create bs file!\n");
		return -1;
	}

	VERBOSE0 (" Start register config! \n");

	// source address
	addr = (uint64_t)src;
	action_write(dnc, REG_ORI_BASE_HIGH, (uint32_t)(addr >> 32));
	action_write(dnc, REG_ORI_BASE_LOW, (uint32_t)(addr & 0xffffffff));
	VERBOSE1 (" Write REG_ORI_BASE done! \n");

	// target address
	addr = (uint64_t)dest;      
	action_write(dnc, REG_BS_BASE_HIGH, (uint32_t)(addr >> 32));   
	action_write(dnc, REG_BS_BASE_LOW, (uint32_t)(addr & 0xffffffff)); 

	action_write(dnc, REG_LEN, reg_len);


	VERBOSE1 (" Write REG_BS_BASE done! \n");

	VERBOSE1 (" Register config done! \n");

	t_start = get_usec();

	Byte_read = fread(src, 1024, 1, fp_src);
	VERBOSE0("Byte read: %d ",Byte_read);

		// read cur pixel mem : to do
	action_write(dnc, REG_START, 0X00000001);
		
	VERBOSE0("test!\n");
		// Poll status for done signal
		

//		start1 = action_read(dnc,REG_START);
//		bs_0 = action_read(dnc,REG_BS_BASE_LOW);
//		bs_1 = action_read(dnc,REG_BS_BASE_HIGH);
//		reg_2 = action_read(dnc,REG_ORI_BASE_LOW);
//		reg_3 = action_read(dnc,REG_ORI_BASE_HIGH);

//		VERBOSE0("qp:0x%x\nstart:%x\nbs_0:%x\nbs_1:%x\nreg_2:%x\nreg_3:%x\nreg_0:%x\nreg_1:%x\nreg_x:%x\nreg_y:%x\n",qp1,start1,bs_0,bs_1,reg_2,reg_3,reg_0,reg_1,reg_x,reg_y);


	while ((action_read(dnc, SYS_DONE_I) & 0x00000001) == 1) {
		;
	}
	VERBOSE0("test!\n");
	while ((action_read(dnc, SYS_DONE_I) & 0x00000001) == 0) {
		;
	}

	VERBOSE0 ("test!\n");

	VERBOSE0 ("One frame encoded!\n");

		// get bs length

	bs_write = fwrite(dest, 1, 1024, fp_des);
	

	VERBOSE0 ("The number of byte writen: %d\n",bs_write);
	fclose(fp_src);
	fclose(fp_des);

	td = get_usec() - t_start;
	*elapsed = td;

	if (0 != rc) {
		return rc;
	}

	return rc;
}

static struct snap_action* get_action (struct snap_card* handle,
									   snap_action_flag_t flags, int timeout)
{
	struct snap_action* act;

	act = snap_attach_action (handle, ACTION_TYPE_HDL_H265ENC,
							  flags, timeout);

	if (NULL == act) {
		VERBOSE0 ("Error: Can not attach Action: %x\n", ACTION_TYPE_HDL_H265ENC);
		VERBOSE0 ("	   Try to run snap_main tool\n");
	}

	return act;
}

static void usage (const char* prog)
{
	VERBOSE0 ("SNAP String Match (Regular Expression Match) Tool.\n"
			  "	Use Option -p and -q for pattern and packet\n"
			  "	e.g. %s -p <packet file> -q <pattern file> [-vv] [-I]\n",
			  prog);
	VERBOSE0 ("Usage: %s\n"
			  "	-h, --help		   print usage information\n"
			  "	-v, --verbose		verbose mode\n"
			  "	-C, --card <cardno>  use this card for operation\n"
			  "	-V, --version\n"
			  "	-q, --quiet		  quiece output\n"
			  "	-t, --timeout		Timeout after N sec (default 1 sec)\n"
			  "	-I, --irq			Enable Action Done Interrupt (default No Interrupts)\n"
			  , prog);
}

int main (int argc, char* argv[])
{
	char device[64];
	struct snap_card* dn;   /* lib snap handle */
	int card_no = 0;
	int cmd;
	int rc = 1;
	uint64_t cir;
	int timeout = ACTION_WAIT_TIME;
	snap_action_flag_t attach_flags = 0;
	struct snap_action* act = NULL;
	unsigned long ioctl_data;
	uint64_t patt_size = 1024;
	void* src  = alloc_mem(64, patt_size);
	void* dest = alloc_mem(64, patt_size);
	uint64_t td;

	while (1) {
		int option_index = 0;
		static struct option long_options[] = {
			{ "card",	 required_argument, NULL, 'C' },
			{ "verbose",  no_argument,	   NULL, 'v' },
			{ "help",	 no_argument,	   NULL, 'h' },
			{ "version",  no_argument,	   NULL, 'V' },
			{ "quiet",	no_argument,	   NULL, 'q' },
			{ "timeout",  required_argument, NULL, 't' },
			{ "irq",	  no_argument,	   NULL, 'I' },
			{ 0,		  no_argument,	   NULL, 0   },
		};
		cmd = getopt_long (argc, argv, "C:t:IqvVh",
						   long_options, &option_index);

		if (cmd == -1) { /* all params processed ? */
			break;
		}

		switch (cmd) {
		case 'v':   /* verbose */
			verbose_level++;
			break;

		case 'V':   /* version */
			VERBOSE0 ("%s\n", version);
			exit (EXIT_SUCCESS);;

		case 'h':   /* help */
			usage (argv[0]);
			exit (EXIT_SUCCESS);;

		case 'C':   /* card */
			card_no = strtol (optarg, (char**)NULL, 0);
			break;

		case 't':
			timeout = strtol (optarg, (char**)NULL, 0); /* in sec */
			break;

		case 'I':	  /* irq */
			attach_flags = SNAP_ACTION_DONE_IRQ | SNAP_ATTACH_IRQ;
			break;

		default:
			usage (argv[0]);
			exit (EXIT_FAILURE);
		}
	}

	VERBOSE0 ("Init memory.\n");
	rc = mem_init(src, dest, patt_size);

	VERBOSE2 ("Open Card: %d\n", card_no);
	sprintf (device, "/dev/cxl/afu%d.0s", card_no);
	dn = snap_card_alloc_dev (device, SNAP_VENDOR_ID_IBM, SNAP_DEVICE_ID_SNAP);

	if (NULL == dn) {
		errno = ENODEV;
		VERBOSE0 ("ERROR: snap_card_alloc_dev(%s)\n", device);
		return -1;
	}

	/* Read Card Capabilities */
	snap_card_ioctl (dn, GET_CARD_TYPE, (unsigned long)&ioctl_data);
	VERBOSE1 ("SNAP on ");

	//	switch (ioctl_data) {
	//	case  0:
	//		VERBOSE1 ("ADKU3");
	//		break;
	//
	//	case  1:
	//		VERBOSE1 ("N250S");
	//		break;
	//
	//	case 16:
	//		VERBOSE1 ("N250SP");
	//		break;
	//
	//	default:
	//		VERBOSE1 ("Unknown");
	//		break;
	//	}

	//snap_card_ioctl (dn, GET_SDRAM_SIZE, (unsigned long)&ioctl_data);
	//VERBOSE1 (" Card, %d MB of Card Ram avilable.\n", (int)ioctl_data);

	snap_mmio_read64 (dn, SNAP_S_CIR, &cir);
	VERBOSE0 ("Start of Card Handle: %p Context: %d\n", dn,
			  (int) (cir & 0x1ff));

	VERBOSE0 ("Start to get action.\n");

	act = get_action (dn, attach_flags, 5 * timeout);

	if (NULL == act) {
		goto __exit1;
	}

	VERBOSE0 ("Finish get action.\n");

	VERBOSE0 ("Start H265 Encoding.\n");
	rc = do_action (dn, src, dest,  &td);

	snap_detach_action (act);

__exit1:
	// Unmap AFU MMIO registers, if previously mapped
	VERBOSE2 ("Free Card Handle: %p\n", dn);
	snap_card_free (dn);

	free_mem(src);
	free_mem(dest);

	VERBOSE1 ("End of Test rc: %d\n", rc);
	return rc;
}
