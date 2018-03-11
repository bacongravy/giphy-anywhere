.PHONY: all install clean

BUILD_PRODUCT := build/GIPHY\ Anywhere.app

all: $(BUILD_PRODUCT)

install: $(BUILD_PRODUCT)
	open "$<"

$(BUILD_PRODUCT): src/main.js
	mkdir -p build
	osacompile -s -o "$@" -l JavaScript -s "$<"
	/usr/libexec/PlistBuddy "$@/Contents/Info.plist" -c "Add :LSUIElement bool YES"

clean:
	rm -rf build
