GCC         = g++
BUILD_FLAGS = -std=c++17

SRC_DIR   = src
BUILD_DIR = build

all: $(BUILD_DIR)/syntaxer

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h:
	bison -t -v -d -b $(BUILD_DIR)/parser $(SRC_DIR)/parser.y

$(BUILD_DIR)/lex.yy.c: $(SRC_DIR)/scanner.l
	flex -o $@ $<

$(BUILD_DIR)/statements: $(SRC_DIR)/statements/statements.cpp
	$(GCC) $(BUILD_FLAGS) -c -o $@ $<

$(BUILD_DIR)/translator: $(SRC_DIR)/translator/translator.cpp
	$(GCC) $(BUILD_FLAGS) -c -o $@ $<

$(BUILD_DIR)/syntaxer: $(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/statements $(BUILD_DIR)/translator
	$(GCC) $(BUILD_FLAGS) -o $@ $^

clean:
	rm -f $(BUILD_DIR)/*

run: $(BUILD_DIR)/syntaxer
	$< $(ARGS)

rebuild: clean $(BUILD_DIR)/syntaxer

.PHONY: all clean run rebuild