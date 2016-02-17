.PHONY: all clean distclean test

NODE_DIR := node_modules
NPM_BIN := $(NODE_DIR)/.bin
COFFEE_CC := $(NPM_BIN)/coffee
JISON := $(NPM_BIN)/jison

DEPS := $(COFFEE_CC) $(JISON)

SRC_IN := $(wildcard *.coffee)
SRC_OUT := $(SRC_IN:.coffee=.js)

COFFEE_FLAGS := -bc --no-header

LEXERS := $(wildcard *.l)
GRAMMARS := $(wildcard *.y)
PARSERS := $(GRAMMARS:.y=.tab.js)

TEST_SCRIPT := test.sh

all: $(SRC_OUT) $(PARSERS)

clean:
	rm -f $(SRC_OUT) $(PARSERS)

distclean: clean
	rm -rf $(NODE_DIR)

test: all $(TEST_SCRIPT)
	sh $(TEST_SCRIPT)

%.js: %.coffee $(COFFEE_CC)
	$(COFFEE_CC) $(COFFEE_FLAGS) $<

JISON_WRAPPER := jison-wrapper.sh
ifeq ($(DEBUG),1)
%.tab.js: %.y %.l $(JISON) .FORCE
	$(JISON_WRAPPER) $@ $^ 1
else
%.tab.js: %.y %.l $(JISON)
	$(JISON_WRAPPER) $@ $^
endif

$(DEPS):
	npm install

.FORCE: