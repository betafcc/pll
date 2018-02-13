REQ_VER := 3.6
REQ_PY := $(shell python3 -V | python3 -c "print('python3' if float(input().split()[1][:3]) >= $(REQ_VER) else '')")
REQ_PY := $(shell command -v $(REQ_PY))
REQUIREMENTS := requirements.txt

ENV_DIR      := venv
ENV_BIN      := $(ENV_DIR)/bin
ENV_ACTIVATE := $(ENV_BIN)/activate
PY           := $(ENV_BIN)/python
PIP          := $(ENV_BIN)/pip

SRC_DIR  := pll
TEST_DIR := test


init: $(ENV_ACTIVATE)

dev:
	$(MAKE) watch WATCH_COMMAND=validate


$(ENV_ACTIVATE): $(REQUIREMENTS)
ifdef REQ_PY
	virtualenv -p $(REQ_PY) $(ENV_DIR)
	$(PIP) install -r $(REQUIREMENTS)
	touch $(ENV_ACTIVATE)
else
	$(error Required Python version $(REQ_VER) or above to build)
endif


.PHONY: clean clean_hard lint typecheck test validate watch

clean:
	rm -rf build *.egg .mypy_cache cache
	find . | grep -E "__pycache__|\.pyc$$|\.pyo$$" | xargs rm -rf


clean_hard:
	rm -rf $(ENV_DIR)
	$(MAKE) clean


lint:
	@echo "***" $@ "***"
	$(PY) -m flake8


typecheck:
	@echo "***" $@ "***"
	$(PY) -m mypy $(SRC_DIR)

test:
	@echo "***" $@ "***"
	$(PY) -m pytest

validate:
	$(MAKE) lint && \
	$(MAKE) typecheck && \
	$(MAKE) test

# watch:
# 	while true; do \
# 		clear; \
# 		$(MAKE) $(WATCH_COMMAND); \
# 		inotifywait -qre close_write $(SRC_DIR) $(TEST_DIR); \
# 	done

watch:
	fswatch -r -l 1 $(SRC_DIR) $(TEST_DIR) | \
		while read change; do \
			clear; \
			$(MAKE) $(WATCH_COMMAND); \
		done
