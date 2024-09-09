CFLAGS := -Wall -Wextra -std=c++17 -w # Compiler flags
EMCC_CFLAGS := $(CFLAGS) --bind -s ASSERTIONS=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s EXIT_RUNTIME=0 -s EXPORTED_FUNCTIONS="[]" -s WASM=1 -s MODULARIZE=1 -s NO_EXIT_RUNTIME=1
MAKEFILES := $(wildcard **/tests/Makefile)

.PHONY: all

all: $(MAKEFILES)
	@ret=0; \
	for makefile in $(MAKEFILES); do \
		$(MAKE) -C $$(dirname $$makefile) CFLAGS="$(CFLAGS)" EMCC_CFLAGS="$(EMCC_CFLAGS)" || { ret=$$?; }; \
	done; \
	exit $$ret

clean: $(MAKEFILES)
	@for makefile in $(MAKEFILES); do \
		echo "Cleaning $$makefile"; \
		$(MAKE) -C $$(dirname $$makefile) clean; \
	done
