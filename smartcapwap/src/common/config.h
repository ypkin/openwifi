#ifndef CONFIG_H_
#define CONFIG_H_

#define LOGLOG_LEVEL	LOG_DEBUG

/* Disable logging debug */
/* #undef DISABLE_LOGGING_DEBUG */

/* Enable logging */
#define ENABLE_LOGGING 1

//#define LOG_TO_SYSLOG

/* config_lookup_int() argument type */
#define LIBCONFIG_LOOKUP_INT_ARG int

/* Use debug backtrace */
#define USE_DEBUG_BACKTRACE 1

#endif
