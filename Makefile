HOMEPAGE = homepage

.sync: $(HOMEPAGE)/index.html
	touch $@ ; \
	(cd $(HOMEPAGE) ; \
		git commit -m "regenerated" index.html ; \
		git push)

# exports to "flat XML", which we don't want
# 
# 3\ star\ OpenDocument/schedule.ods: 2\ star\ Excel/schedule.xls
# 	soffice --headless --convert-to ods --outdir "$$(dirname "$@")" "$<"

3.5\ star\ CSV/schedule.csv: 3\ star\ OpenDocument/schedule.ods
	soffice --headless --convert-to csv --outdir "$$(dirname "$@")" "$<"

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
