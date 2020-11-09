.PHONY: test
test: export MIX_ENV=test
test: deps
	mix test

.PHONY: deps
deps:
	mix deps.get

.PHONY: clean
clean:
	rm -fr _build deps

.PHONY: publish
publish:
	mix hex.publish

