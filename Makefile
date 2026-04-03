.PHONY: build install uninstall test clean reset

APP       = QuickLookMax
SCHEME    = QuickLookMax
PROJECT   = QuickLookMax.xcodeproj
BUILD_DIR = .build
INSTALL   = $(HOME)/Applications

# ──────────────────────────────────────────────
# Build (Debug, no Apple Developer account needed)
# ──────────────────────────────────────────────
build:
	@which xcpretty > /dev/null 2>&1 || gem install xcpretty --silent
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty 2>/dev/null || true

# ──────────────────────────────────────────────
# Install to ~/Applications + register extension
# ──────────────────────────────────────────────
install: build
	mkdir -p $(INSTALL)
	rm -rf $(INSTALL)/$(APP).app
	cp -R $(BUILD_DIR)/Build/Products/Debug/$(APP).app $(INSTALL)/$(APP).app
	@echo "✅  Installed to $(INSTALL)/$(APP).app"
	@echo "➡️  Opening app to register the Quick Look extension..."
	open $(INSTALL)/$(APP).app
	sleep 1
	$(MAKE) reset

# ──────────────────────────────────────────────
# Reset Quick Look cache (after install or code change)
# ──────────────────────────────────────────────
reset:
	qlmanage -r
	qlmanage -r cache
	@echo "✅  Quick Look cache reset"

# ──────────────────────────────────────────────
# Test: preview a file directly in terminal
# Usage: make test FILE=~/Desktop/README.md
# ──────────────────────────────────────────────
test:
	qlmanage -p $(FILE)

# ──────────────────────────────────────────────
# Uninstall
# ──────────────────────────────────────────────
uninstall:
	rm -rf $(INSTALL)/$(APP).app
	qlmanage -r
	@echo "✅  Removed $(APP)"

# ──────────────────────────────────────────────
# Clean build artifacts
# ──────────────────────────────────────────────
clean:
	rm -rf $(BUILD_DIR)
	@echo "✅  Build folder removed"
