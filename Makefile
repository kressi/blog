SHELL := /bin/bash
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

.PHONY: all $(MAKECMDGOALS) 

.SILENT:

all: clean build tidy check

clean:
	printf "$(GRN)Clean $(PUBLIC_FOLDER)...$(END)\n"
	cd $(PUBLIC_FOLDER)
	ls -A | awk !'or(/README.md/,/.git/)' | xargs rm -rf

build:
	printf "$(GRN)Build site...$(END)\n"
	hugo --theme $(HUGO_THEME)

tidy:
	printf "$(GRN)Tidy site...$(END)\n"
	hash $(TIDY_CMD) 2>/dev/null && \
		( find $(PUBLIC_FOLDER) -type f -name '*.html' -print \
		-exec $(TIDY_CMD) -config $(TIDY_CONF) '{}' \;) || \
		printf "$(RED)$(TIDY_CMD) is not installed$(END)\n"

check:
	printf "$(GRN)Check site...$(END)\n"
	hugo check
	hash $(HTMLPROOFER_CMD) 2>/dev/null && \
		$(HTMLPROOFER_CMD) --check-html $(PUBLIC_FOLDER) || \
		printf "$(RED)$(HTMLPROOFER_CMD) is not installed$(END)\n"

deploy: all
	printf "$(GRN)Deploy to GitHub...$(END)\n"
	cd $(PUBLIC_FOLDER)
	git add .
	$(eval msg = $(or "$(m)", "Rebuild site $(shell date)"))
	git commit -m $(msg) || :
	git push origin master || :

