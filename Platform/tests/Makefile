CC := g++ # C++ compiler
CFLAGS := -Wall -Wextra -std=c++17 -w # Compiler flags
SRCS := $(wildcard *.cpp) # Get all .cpp files in the current directory
OBJS := $(SRCS:.cpp=.o) # Object files corresponding to the source files

all: $(OBJS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -v $(OBJS)
