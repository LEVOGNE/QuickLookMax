.PHONY: build install uninstall test clean reset

APP       = QuickLookMax
SCHEME    = QuickLookMax
PROJECT   = QuickLookMax.xcodeproj
BUILD_DIR = .build
INSTALL   = /Applications
TEAM_ID   = GKTDLS7Q7V
SIGN_ID   = Apple Development: Levent Ersen (WFQ78JBU4T)
APPEX     = $(INSTALL)/$(APP).app/Contents/PlugIns/QuickLookMaxExtension.appex

# ──────────────────────────────────────────────
# Build + sign with Developer ID certificate
# ──────────────────────────────────────────────
build:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_STYLE=Manual \
		CODE_SIGN_IDENTITY="$(SIGN_ID)" \
		DEVELOPMENT_TEAM=$(TEAM_ID) \
		CODE_SIGNING_REQUIRED=YES \
		2>&1 | grep -E "^(error:|warning:|Build succeeded|FAILED|CompileSwift|Ld )" || true

# ──────────────────────────────────────────────
# Install to /Applications + register extension
# ──────────────────────────────────────────────
install: build
	rm -rf $(INSTALL)/$(APP).app
	cp -R $(BUILD_DIR)/Build/Products/Debug/$(APP).app $(INSTALL)/$(APP).app
	@echo "📦  Registering extension..."
	pluginkit -r $(BUILD_DIR)/Build/Products/Debug/$(APP).app/Contents/PlugIns/QuickLookMaxExtension.appex 2>/dev/null || true
	pluginkit -a $(APPEX)
	@echo "✅  Installed to $(INSTALL)/$(APP).app"
	open $(INSTALL)/$(APP).app
	sleep 2
	$(MAKE) reset

# ──────────────────────────────────────────────
# Reset Quick Look cache
# ──────────────────────────────────────────────
reset:
	qlmanage -r
	qlmanage -r cache
	@echo "✅  Quick Look cache reset"

# ──────────────────────────────────────────────
# Test a specific file: make test FILE=~/path/to/file.md
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
