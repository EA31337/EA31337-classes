CFLAGS := -Wall -Wextra -std=c++17 -w # Compiler flags
MAKEFILES := $(wildcard **/tests/Makefile)

.PHONY: all

all: $(MAKEFILES)
	@for makefile in $(MAKEFILES); do \
		echo "Compiling $$makefile"; \
		$(MAKE) -C $$(dirname $$makefile) CFLAGS="$(CFLAGS)"; \
	done

clean: $(MAKEFILES)
	@for makefile in $(MAKEFILES); do \
		echo "Compiling $$makefile"; \
		$(MAKE) -C $$(dirname $$makefile) clean; \
	done
