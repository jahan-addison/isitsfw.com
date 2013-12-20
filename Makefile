REPORTER = dot

test:
	@echo "::::Links NSFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/links_no_tests.js
	@echo "::::Images SFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/images_yes_tests.js
	@echo "::::Images NSFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/images_no_tests.js
	@echo "::::Files MAYBE SFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/files_maybe_tests.js
	@echo "::::Files NOT SURE SFW test---"
	./node_modules/.bin/mocha --reporter $(REPORTER) ./tests/files_not_sure_tests.js

.PHONY: test