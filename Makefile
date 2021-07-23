#
# Makefile
#

CIBUILD			?= false
BUILD_TYPE	?= Debug
PROJECT_DIR	:= $(PWD)
DRY_RUN			?= true

ifeq ($(CIBUILD), true)
    BUILD_TYPE = Release
    DRY_RUN = false
endif

.PHONY: setup update test build format lint cibuild integrationtests publish

setup:
	$(PROJECT_DIR)/scripts/setup ${BUILD_TYPE}

update:
	$(PROJECT_DIR)/scripts/update

test:
	$(PROJECT_DIR)/scripts/test

build:
	$(PROJECT_DIR)/scripts/build ${BUILD_TYPE}

format:
	$(PROJECT_DIR)/scripts/format

lint:
	$(PROJECT_DIR)/scripts/lint

cibuild:
	$(PROJECT_DIR)/scripts/cibuild ${BUILD_TYPE}

integrationtests:
	$(PROJECT_DIR)/scripts/integrationtests ${BUILD_TYPE}

publish: setup
	$(PROJECT_DIR)/scripts/publish ${BUILD_TYPE} ${DRY_RUN}
