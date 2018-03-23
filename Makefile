.PHONY: all install clean

BUILD_PRODUCT := build/GIPHY\ Anywhere.app

build:
	mkdir -p build

build/%: rsrc/%.erb build
	erb -T - "$<" > "$@"

$(BUILD_PRODUCT): src/main.js build/Info.plist build
	rm -rf "$@"
	osacompile -s -o "$@" -l JavaScript -s "$<"
	cp build/Info.plist "$@/Contents/Info.plist"

all: $(BUILD_PRODUCT)

install: $(BUILD_PRODUCT)
	open "$<"

clean:
	rm -rf build
