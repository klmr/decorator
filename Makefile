.PHONY: test
test:
	Rscript ./decorate.r

.PHONY: example
example: examples.md

%.md: %.rmd
	Rscript -e 'library(modules); knitr::knit("$<", "$@")'
