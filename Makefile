CFLAGS := -Wall -Wextra -std=c++17 -w # Compiler flags
EMCC_CFLAGS := $(CFLAGS) --bind -s ASSERTIONS=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s EXIT_RUNTIME=0 -s EXPORTED_FUNCTIONS="[]" -s WASM=1 -s MODULARIZE=1 -s NO_EXIT_RUNTIME=1
MAKEFILES := $(wildcard **/tests/Makefile) $(wildcard **/**/tests/Makefile)

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

all: cpp

cpp mql mql4 mql5: $(MAKEFILES)
	@ret=0; \
	for makefile in $(MAKEFILES); do \
		$(MAKE) -C $$(dirname $$makefile) WINE='$(WINE)' WINEPATH='$(WINEPATH)' $@ || { ret=$$?; }; \
	done; \
	exit $$ret

clean: $(MAKEFILES)
	@for makefile in $(MAKEFILES); do \
		echo "Cleaning $$makefile"; \
		$(MAKE) -C $$(dirname $$makefile) clean; \
	done
