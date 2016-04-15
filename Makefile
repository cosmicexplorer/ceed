# `make test DEBUG=1` to force debug on tests
# `make DEBUG_PARSER=1` to force jison to show debug output when generating

.PHONY: all clean distclean test

NODE_DIR := node_modules
NPM_BIN := $(NODE_DIR)/.bin
COFFEE_CC := $(NPM_BIN)/coffee
JISON := $(NPM_BIN)/jison
NODE_UNIT := $(NPM_BIN)/nodeunit
NODE_INSPECTOR := $(NPM_BIN)/node-inspector

DEPS := $(COFFEE_CC) $(JISON) $(NODE_INSPECTOR)

SRC_IN := $(wildcard *.coffee)
SRC_OUT := $(SRC_IN:.coffee=.js)
SRC_MAPS := $(SRC_IN:.coffee=.js.map)

COFFEE_FLAGS := -bcm --no-header

LEXERS := $(wildcard *.l)
GRAMMARS := $(wildcard *.y)
PARSERS := $(GRAMMARS:.y=.tab.js)

TEST_DIR := test
TEST_SRC := $(wildcard $(TEST_DIR)/*.coffee)
TEST_OUT := $(TEST_SRC:.coffee=.js)
TEST_MAP := $(TEST_SRC:.coffee=.js.map)

all: $(SRC_OUT) $(PARSERS)

clean:
	rm -f $(SRC_OUT) $(PARSERS) $(SRC_MAPS)
	rm -f $(TEST_OUT) $(TEST_MAP)

distclean: clean
	rm -rf $(NODE_DIR)

test: all $(TEST_SCRIPT) $(TEST_OUT)
ifeq ($(DEBUG),1)
	$(NODE_INSPECTOR) &
	node --debug-brk $(NODE_UNIT) $(TEST_OUT)
else
	$(NODE_UNIT) $(TEST_OUT)
endif

%.js: %.coffee $(COFFEE_CC)
	$(COFFEE_CC) $(COFFEE_FLAGS) $<

JISON_WRAPPER := jison-wrapper.sh
ifeq ($(DEBUG_PARSER),1)
%.tab.js: %.y %.l $(JISON) .FORCE
	$(JISON_WRAPPER) $@ $^ 1
else
%.tab.js: %.y %.l $(JISON)
	$(JISON_WRAPPER) $@ $^
endif

$(DEPS):
	npm install

.FORCE:
