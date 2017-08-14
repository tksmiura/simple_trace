#ifndef __SIMPLE_TRACE_H__
#define __SIMPLE_TRACE_H__

#ifdef __TRACE_ON__
#define TRACE_EVENT(from, to, fmt, ...) \
    printf("EVENT %s ->> %s: " fmt "\n", (from), (to), ##__VA_ARGS__)

#define TRACE_NOTE(fmt, ...) \
    printf("NOTE " __FILE__ ": " fmt "\n", ##__VA_ARGS__);

#else
#define TRACE_EVENT(from, to, fmt, ...)
#define TRACE_NOTE(fmt, ...)
#endif

#endif /* __SIMPLE_TRACE_H__ */
