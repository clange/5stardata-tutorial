HOMEPAGE = homepage

.sync: $(HOMEPAGE)/index.html
	touch $@ ; \
	(cd $(HOMEPAGE) ; \
		git commit -m "regenerated" index.html ; \
		git push)

3.5\ star\ CSV/schedule.csv: 3\ star\ OpenDocument/schedule.ods
	soffice --headless --convert-to csv --outdir "$$(dirname "$@")" 3\ star\ OpenDocument/schedule.ods

homepage/index.html: README.org
	emacs --batch \
		-Q \
		--eval "(progn \
				(require 'package) \
				(package-initialize) \
				(require 'org) \
				)" \
		$< \
		-f org-html-export-to-html ; \
	mv $(subst .org,.html,$<) $@

.PHONY: clean
