.PHONY: all forge render

all: forge render list

list:
	@find build_artifacts -name "*.conda" ! -path "*/pkg_cache/*"

forge:
	@conda install -c conda-forge -y conda-smithy conda-verify conda-package-handling anaconda-client

render:
	@conda smithy rerender --no-check-uptodate
	@echo "!Makefile" >> .gitignore
	@echo "!.github"  >> .gitignore
	@git add .gitignore

ANACONDA_TOKEN := "$(HOME)/.conda-smithy/anaconda.token"
anaconda:

	@if [ ! -f "$(ANACONDA_TOKEN)" ]; then \
            echo "Error: Anaconda token not found at $(ANACONDA_TOKEN)"; \
            exit 1; \
        fi

	@for PACKAGE in $(shell find build_artifacts -name "*.conda" ! -path "*/pkg_cache/*"); do \
            conda-verify $$PACKAGE; \
            anaconda -t $(ANACONDA_TOKEN) upload --force $$PACKAGE --label test; \
        done

debug:
	@conda debug . --output /home/marco.meyer/.conda/conda-bld/debug_1740216566494/linux-64/framel-8.48.4-py310h3fd9d12_0.tar.bz2
