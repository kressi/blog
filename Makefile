.PHONY: tidy deploy

tidy:
	find public/ -type f -name '*.html' -print \
		-exec tidy -config .tidyrc '{}' \;

deploy:
	./deploy.sh

