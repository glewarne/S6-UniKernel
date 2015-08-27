#define VARDET_UNKNOWN	0

/* models below do not require aif_format from dtb blob */
#define VARDET_G920F	1
#define VARDET_G925F	2
#define VARDET_G920I	3
#define VARDET_G925I	4
#define VARDET_G920S	5
#define VARDET_G925S	6
#define VARDET_G920K	7
#define VARDET_G925K	8
#define VARDET_G920L	9
#define VARDET_G925L	10

/* models below require aif_format from dtb blob */
#define VARDET_G920T	11
#define VARDET_G925T	12
#define VARDET_G920W8	13
#define VARDET_G925W8	14
#define VARDET_G920P	15
#define VARDET_G925P	16


/* For simple if..else chacks */
#define NO_AIF		0
#define HAS_AIF		1


/*Edge or Not*/
#define IS_EDGE		1
#define NOT_EDGE	0

extern unsigned int model_type;
extern unsigned int variant_aif_required;
extern unsigned int variant_edge;

