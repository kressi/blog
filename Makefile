# https://github.com/marcanuy/hugo-deploy-aws-makefile/blob/master/Makefile
.PHONY: clean build tidy check deploy

PUBLIC_FOLDER := public
DEPLOY_SCRIPT := deploy.sh
TIDY_CONF := tidy.conf

clean:
	cd $(PUBLIC_FOLDER) ; \
		\ls -A | awk !'or(/README.md/,/.git/)' | xargs rm -rf

build: clean
	hugo --theme hugo-flex

tidy:
	find $(PUBLIC_FOLDER) -type f -name '*.html' -print \
		-exec tidy -config $(TIDY_CONF) '{}' \;

check:
	htmlproofer --check-html $(PUBLIC_FOLDER)

deploy: build tidy check
	./$(DEPLOY_SCRIPT)

