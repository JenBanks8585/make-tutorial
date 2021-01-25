SHELL = /bin/bash
ACTIVATE_VENV = source venv/bin/activate

.PHONY: all
all: clean data/color_films_by_year.png

venv: requirements.txt
	test -d $@ || python3 -m venv $@
	$(ACTIVATE_VENV) && pip install -r $<
	touch $@

data/films.csv: venv
	test -d data || mkdir data
	$(ACTIVATE_VENV) && python src/oscar_nominees.py $@

data/film_color_data.csv: data/films.csv
	$(ACTIVATE_VENV) && python src/film_color.py $< $@

data/color_films_by_year.png: data/film_color_data.csv
	$(ACTIVATE_VENV) && python src/color_films_by_year.py $< $@

# Utility
.PHONY: clean
clean:
	rm -rf venv
	find . | grep __pycache__ | xargs rm -rf

.PHONY: tests test-unit test-lint
tests: test-lint test-unit

test-unit: venv
	$(ACTIVATE_VENV) && pytest -s tests

test-lint: venv
	$(ACTIVATE_VENV) && flake8 src