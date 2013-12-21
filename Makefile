REPORTER = dot

test:
	@echo "::::Links NSFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/links_nsfw_tests.js
	@echo "::::Images SFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/images_sfw_tests.js
	@echo "::::Images NSFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/images_nsfw_tests.js
	@echo "::::Files MAYBE SFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/files_maybe_sfw_tests.js
	@echo "::::Files NOT SURE SFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/files_not_sure_sfw_tests.js

.PHONY: test