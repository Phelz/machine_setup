SHELL := /bin/bash

# Usage:
# 1. Copy this Makefile to the root directory of the project
# 2. Run 'make setup' to create the Conda environment and install the development package
# 3. (Optional) Run 'sudo make install_fonts' to install Microsoft TrueType core fonts if needed

# Pick an enviroment name and python verison
ENV_NAME := test_03
PYTHON_VERSION := 3.12.0
PYTHON_VERSION_TRUNCATED := $(shell echo $(PYTHON_VERSION) | cut -d. -f1,2)
# --------------------------------------------------

CONDAROOT ?= /home/$(USER)/anaconda3
MATPLOTLIBRC_URL := https://archive.org/download/matplotlibrc_202411/matplotlibrc
MATPLOTLIBRC_DIR := $(CONDAROOT)/envs/$(ENV_NAME)/lib/python$(PYTHON_VERSION_TRUNCATED)/site-packages/matplotlib/mpl-data/

.PHONY: setup init install message update_matplotlibrc

setup: init install message update_matplotlibrc

init: 
	@echo "Initializing..."
	@chmod -R 755 src/
	@echo "Using python=$(PYTHON_VERSION) and environment name=$(ENV_NAME)"

	@echo "name: $(ENV_NAME)" > environment.yml
	@echo "channels:" >> environment.yml
	@echo "- anaconda" >> environment.yml
	@echo "- defaults" >> environment.yml
	@echo "dependencies:" >> environment.yml
	@echo "- matplotlib" >> environment.yml
	@echo "- python=$(PYTHON_VERSION)" >> environment.yml
	# @echo "- pandas" >> environment.yml

install:
	@echo "Creating and setting up the Conda environment..."
	@source $(CONDAROOT)/bin/activate && conda env create -n $(ENV_NAME) -f environment.yml -y
	@echo "Installing development package..."
	@source $(CONDAROOT)/bin/activate $(ENV_NAME) && conda develop .

update_matplotlibrc:
	@echo "Downloading updated matplotlibrc file..."
	@wget -O /tmp/matplotlibrc $(MATPLOTLIBRC_URL)
	@echo "Updating matplotlibrc configuration..."
	@python update_matplotlibrc.py $(MATPLOTLIBRC_DIR)/matplotlibrc /tmp/matplotlibrc
	@rm /tmp/matplotlibrc
	@echo "Matplotlibrc updated."


message:
	@echo "=================================================="
	@echo "Setup completed. Activate the environment with 'conda activate $(ENV_NAME)'"
	@echo "=================================================="


install_fonts: download_ttcf clean_matplotlib_cache

download_ttcf:
	@echo "Installing Microsoft TrueType core fonts. This requires administrative privileges:"
	@echo "Running 'sudo apt install msttcorefonts -qq'"
	@sudo apt install msttcorefonts -qq

clean_matplotlib_cache:
	@echo "Cleaning Matplotlib cache..."
	@rm -rf ~/.cache/matplotlib