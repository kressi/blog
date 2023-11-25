SHELL := /bin/bash
DOMAIN := www.lunulata.io
PUBLIC_FOLDER := public
HUGO_THEME := hugo-flex
TIDY_CMD := tidy
TIDY_CONF := tidy.conf
HTMLPROOFER_CMD := htmlproofer
RED := \e[1;31m
GRN := \e[1;32m
END := \e[0m

.SHELLFLAGS = -c -o pipefail -e

.ONESHELL:

.SILENT:

.PHONY: all
all: clean build tidy check

.PHONY: clean
clean:
	printf "$(GRN)Clean $(PUBLIC_FOLDER)...$(END)\n"
	cd $(PUBLIC_FOLDER)
	ls -A | grep -v 'README.md\|.git' | xargs rm -rf

.PHONY: update-theme
update-theme:
	git submodule update --remote --rebase

.PHONY: build
build:
	printf "$(GRN)Build site...$(END)\n"
	hugo --theme $(HUGO_THEME)

.PHONY: tidy
tidy:
	printf "$(GRN)Tidy site...$(END)\n"
ifeq (, $(shell hash $(TIDY_CMD) 2>/dev/null))
	find $(PUBLIC_FOLDER) -type f -name '*.html' -print \
		-exec $(TIDY_CMD) -config $(TIDY_CONF) '{}' \;
else
	printf "$(RED)$(TIDY_CMD) is not installed$(END)\n"
endif

.PHONY: check
check:
	printf "$(GRN)Check site...$(END)\n"
ifeq (, $(shell hash $(HTMLPROOFER_CMD) 2>/dev/null))
	$(HTMLPROOFER_CMD) $(PUBLIC_FOLDER)
else
	printf "$(RED)$(HTMLPROOFER_CMD) is not installed$(END)\n"
endif

.PHONY: publish
publish:
	printf "$(GRN)Publish to GitHub...$(END)\n"
	cd $(PUBLIC_FOLDER)
	git add .
	$(eval msg = $(or $(m), "Rebuild site $(shell date)"))
	git commit -m $(msg) || :
	git push origin main || :

.PHONY: deploy
deploy: all publish
