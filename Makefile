DEVTOOLS_PYTHON := $(if $(wildcard .tools/devtools-venv/bin/python),.tools/devtools-venv/bin/python,python3)
DEVTOOLS := $(DEVTOOLS_PYTHON) scripts/botecopro.py

.PHONY: help bootstrap doctor bootstrap-info tooling-test \
	mobile-get mobile-format mobile-analyze mobile-test mobile-build mobile-check mobile-lint \
	android-doctor android-build android-smoke android-evidence evidence-audit report \
	verify verify-android website-dev website-build test lint

help:
	@printf '%s\n' \
	  'bootstrap          Create/reuse the local Python devtools venv' \
	  'doctor             Diagnose the complete local toolchain (read-only)' \
	  'tooling-test       Test critical Python developer-tool logic' \
	  'mobile-get         Install Flutter dependencies' \
	  'mobile-format      Check Dart formatting' \
	  'mobile-analyze     Run Flutter analyzer with fatal infos' \
	  'mobile-test        Run Flutter tests' \
	  'mobile-build       Build the Android debug APK' \
	  'mobile-check       Run get, format, analyze and tests' \
	  'android-doctor     Diagnose Android build/device/emulator capability' \
	  'android-build      Build the Android debug APK' \
	  'android-smoke      Build/install/launch on one selected Android target' \
	  'android-evidence   Reset dev app data and capture SYNTHETIC evidence' \
	  'evidence-audit     Audit the latest evidence run' \
	  'report             Regenerate reports for the latest evidence run' \
	  'verify             Test tooling, format, analyze, test and build (no emulator)' \
	  'verify-android     Run verify, then Android smoke (does not start an AVD)'

bootstrap:
	./scripts/bootstrap.sh

doctor:
	$(DEVTOOLS) doctor

bootstrap-info:
	$(DEVTOOLS) bootstrap-info

tooling-test:
	$(DEVTOOLS) tooling-test

mobile-get:
	$(DEVTOOLS) flutter-get

mobile-format:
	$(DEVTOOLS) flutter-format

mobile-analyze:
	$(DEVTOOLS) flutter-analyze

mobile-test:
	$(DEVTOOLS) flutter-test

mobile-build:
	$(DEVTOOLS) flutter-build

mobile-check:
	$(DEVTOOLS) flutter-check
	$(DEVTOOLS) flutter-test

mobile-lint: mobile-analyze

android-doctor:
	$(DEVTOOLS) android-doctor

android-build:
	$(DEVTOOLS) android-build

android-smoke:
	$(DEVTOOLS) android-smoke

android-evidence:
	$(DEVTOOLS) android-evidence --evidence-source synthetic --reset-app-data

evidence-audit:
	$(DEVTOOLS) evidence-audit

report:
	$(DEVTOOLS) report

verify:
	$(DEVTOOLS) verify

verify-android:
	$(DEVTOOLS) verify --android

website-dev:
	cd apps/website && npm run dev

website-build:
	cd apps/website && npm run build

test: mobile-test

lint: mobile-analyze
