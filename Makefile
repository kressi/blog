SHELL := /bin/bash
PUBLIC_FOLDER := public
DEPLOY_SCRIPT := deploy.sh
TIDY_CONF := tidy.conf
HUGO_THEME := hugo-flex

.SHELLFLAGS = -c -o pipefail -e

.ONESHELL:

.PHONY: all $(MAKECMDGOALS) 

.SILENT:

all: build tidy check

clean:
	printf "\033[0;32mClean $(PUBLIC_FOLDER)...\033[0m\n"
	cd $(PUBLIC_FOLDER)
	\ls -A | awk !'or(/README.md/,/.git/)' | xargs rm -rf

build: clean
	printf "\033[0;32mBuild site...\033[0m\n"
	hugo --theme $(HUGO_THEME)

tidy:
	printf "\033[0;32mTidy site...\033[0m\n"
	find $(PUBLIC_FOLDER) -type f -name '*.html' -print \
		-exec tidy -config $(TIDY_CONF) '{}' \;

check:
	printf "\033[0;32mCheck site...\033[0m\n"
	hugo check
	htmlproofer --check-html $(PUBLIC_FOLDER)

deploy: build tidy check
	printf "\033[0;32mDeploy to GitHub...\033[0m\n"
	cd $(PUBLIC_FOLDER)
	git add .
	$(eval msg = $(or "$(m)", "Rebuild site $(shell date)"))
	git commit -m $(msg) || :
	git push origin master || :

