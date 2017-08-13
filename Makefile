## usage
#
# - 'make'
#    build target normally
# - 'make debug'
#    build target with debug option
#    and run debugger
# - 'make test'
#    build unit test and run
# - 'make gcov'
#    build unit test and run
#    get coverage using gcov
# - 'make trace'
#    execute program and make trace

#TARGETS
PROGRAM = main
DEBUG_TARGET = main_debug
TRACE_TARGET = main_trace
HEADERS = $(wildcard *.h)
SRCS = main.c sub.c
TEST_SRCS = $(wildcard ut_*.c)
TESTS = $(basename $(TEST_SRCS)) 
GCOV_TESTS = $(TEST_SRCS:.c=_gcov)

# ENVIRONMENT
CC ?= gcc
CFLAGS ?= -Wall -O2
DEBUG_OPTION ?= -O0 -g
TRACE_OPTION ?= -fPIC -finstrument-functions
DEBUGGER ?= gdb -tui
GCOV ?= gcov
PLANTUML ?= plantuml -tpng

# suffixes
.SUFFIXES: .c .o .debug_o .trace_o

#default target
all: $(PROGRAM)

#
# target(normally)
#
.c.o:
	$(CC) $(CFLAGS) -c $<

define MAKEOBJECTS
$(1:.c=.o): $(1) $(HEADERS)
endef
$(foreach VAR,$(SRCS),$(eval $(call MAKEOBJECTS,$(VAR))))

$(PROGRAM): $(SRCS:.c=.o)
	$(CC) -o $(PROGRAM) $^

#
# debug(gdb)
#
.c.debug_o:
	$(CC) $(DEBUG_OPTION) -o $@ -c $<

define MAKEDEBUG
$(1:.c=.debug_o): $(1) $(HEADERS)
endef
$(foreach VAR,$(SRCS),$(eval $(call MAKEDEBUG,$(VAR))))


$(DEBUG_TARGET): $(SRCS:.c=.debug_o)
	$(CC) -o $@ $^

.PHONY: debug
debug: $(DEBUG_TARGET)
	$(DEBUGGER) $^

#
# unit test 
#

# build targets for test
define MAKETARGETS
$(1): $(1).c $(HEADERS)
	$(CC) -o $(1) $(1).c
endef
$(foreach VAR,$(TESTS),$(eval $(call MAKETARGETS,$(VAR))))

# run tests
.PHONY: test
test: $(TESTS)
	@for test in $(TESTS) ; do \
		./$$test ;\
	done

#
# gcov
#

# target gov (unit test only) 
define MAKETARGETS_GCOV
$(1)_gcov: $(1).c
	$(CC) $(CFLAGS) -o $(1)_gcov --coverage $(1).c
endef
$(foreach VAR,$(TESTS),$(eval $(call MAKETARGETS_GCOV,$(VAR))))

# run unit tests and gcov
.PHONY: gcov
gcov: $(GCOV_TESTS)
	@for test in $(GCOV_TESTS) ; do \
		./$$test ;\
	done
	$(GCOV) -b $(TEST_SRCS:.c=.gcda)

#
# trace
#
.c.trace_o:
	$(CC) $(TRACE_OPTION) -o $@ -c $<

define MAKETRACE
$(1:.c=.trace_o): $(1) $(HEADERS)
endef
$(foreach VAR,$(SRCS),$(eval $(call MAKETRACE,$(VAR))))

libtrace/libsimpletrace.o: libtrace/simple_trace.c
	$(CC) -fPIC -c libtrace/simple_trace.c -o libtrace/libsimpletrace.o

$(TRACE_TARGET): $(SRCS:.c=.trace_o) libtrace/libsimpletrace.o
	$(CC) -Wl,-map,map.txt -o $@ $^

.PHONY: trace
trace: $(TRACE_TARGET)
	./$^ | libtrace/seq_trace.pl main_trace.png > main_trace.uml
	$(PLANTUML) main_trace.uml

#
# clean
#
.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(DEBUG_TARGET) $(TRACE_TARGET)
	$(RM) $(TESTS) $(GCOV_TESTS)
	$(RM) $(SRCS:.c=.o) $(SRCS:.c=.debug_o) $(SRCS:.c=.trace_o)
	$(RM) libtrace/libsimpletrace.o
	$(RM) *.gcda *.gcno *.gcov 
	$(RM) map.txt *.uml *.png
