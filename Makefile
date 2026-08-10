MOBILE := cd apps/mobile &&

.PHONY: help mobile-get mobile-analyze mobile-test mobile-lint website-dev website-build test lint

help:
	@printf '%s\n' \
	  'mobile-get       Install Flutter dependencies' \
	  'mobile-analyze   Run Flutter analyzer' \
	  'mobile-test      Run Flutter tests' \
	  'website-dev      Start website development server' \
	  'website-build    Build website' \
	  'test             Run mobile tests' \
	  'lint             Run mobile analyzer'

mobile-get:
	$(MOBILE) flutter pub get

mobile-analyze:
	$(MOBILE) flutter analyze

mobile-test:
	$(MOBILE) flutter test

mobile-lint: mobile-analyze

website-dev:
	cd apps/website && npm run dev

website-build:
	cd apps/website && npm run build

test: mobile-test

lint: mobile-analyze
