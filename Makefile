.PHONY: all clean distclean

NODE_DIR := node_modules
NPM_BIN := $(NODE_DIR)/.bin
COFFEE := $(NPM_BIN)/coffee

DEPS := $(COFFEE)

COFFEE_OPTS := -bc --no-header

OUT_JS := replace-all.js

all: $(OUT_JS)

%.js: %.coffee $(DEPS)
	$(COFFEE) $(COFFEE_OPTS) $<

clean:
	rm -f $(OUT_JS)

distclean: clean
	rm -rf $(NODE_DIR)

$(DEPS):
	npm install
