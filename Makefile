.PHONY: all quit install uninstall clean

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

quit:
	osascript -e 'tell app "GIPHY Anywhere" to quit'

install: $(BUILD_PRODUCT) quit
	rm -rf "/Applications/GIPHY Anywhere.app"
	cp -R "$<" /Applications/
	open "/Applications/GIPHY Anywhere.app"

uninstall: quit
	rm -rf "/Applications/GIPHY Anywhere.app"

clean:
	rm -rf build
