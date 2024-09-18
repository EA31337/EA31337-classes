CC := g++ # C++ compiler
MTE4 := metaeditor.exe
MTE5 := metaeditor64.exe
CFLAGS := -Wall -Wextra -std=c++17 -w
SRCS_CPP := $(wildcard *.cpp)
SRCS_MQ4 := $(wildcard *.mq4)
SRCS_MQ5 := $(wildcard *.mq5)
OBJS_EX4 := $(SRCS_MQ4:.mq4=.ex4)
OBJS_EX5 := $(SRCS_MQ5:.mq5=.ex5)
OBJS_O := $(SRCS_CPP:.cpp=.o)

# Check if the system is Linux
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    WINE := wine
    # Set WINEPATH to include MetaTrader directory.
    export WINEPATH := $(WINEPATH);"C:\Program Files\MetaTrader 4;C:\Program Files\MetaTrader 5"
else
    WINE :=
endif

.PHONY: all cpp mql mql4 mql5

all: $(OBJS_O)
cpp: $(OBJS_O)
mql4: $(OBJS_EX4)
mql5: $(OBJS_EX5)
mql: mql4 mql5

%.ex4: %.mq4
	$(WINE) $(MTE4) /compile:$< /log:CON

%.ex5: %.mq5
	$(WINE) $(MTE5) /compile:$< /log:CON

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -v $(OBJS_EX4) $(OBJS_EX5) $(OBJS_O)
