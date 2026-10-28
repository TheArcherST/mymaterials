.PHONY: tools build serve check pdf-example deploy

tools:
	python3 tools/install.py

build:
	python3 tools/build.py

serve:
	python3 tools/build.py --serve $(ARGS)

check:
	python3 -m unittest discover -s tests -v

pdf-example:
	mkdir -p .build
	PATH="$(CURDIR)/.tools/bin:$$PATH" typst compile --root . typst/examples/python-state.typ .build/python-state.pdf

deploy: build
	bash tools/deploy.sh .build/public
