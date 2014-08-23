HOMEPAGE = homepage
SYNC_FILES = org-info.js bootstrap.min.css
DEMO_FILES = 1star_PDF/schedule.pdf \
	2star_Excel/schedule.xls \
	3star_OpenDocument/schedule.ods \
	3.5star_CSV/presenters.csv \
	3.5star_CSV/schedule.csv \
	3.5star_CSV/schedule-alt.csv \
	4star_CSV/presenters.csv \
	4star_CSV/schedule.csv \
	4.5star_CSV/presenters.csv \
	4.5star_CSV/schedule-more.csv \
	4.5star_CSV/schedule.csv \
	4.5star_CSV/vocab.csv

.sync: $(HOMEPAGE)/.sync $(HOMEPAGE)/index.html
	(cd $(HOMEPAGE) ; \
		git commit -m "regenerated" index.html ; \
		git push) ; \
	touch $@

$(HOMEPAGE)/.sync: $(DEMO_FILES) $(SYNC_FILES)
	rsync -avR $(DEMO_FILES) $(SYNC_FILES) homepage/ ; \
	touch $@

# exports to "flat XML", which we don't want
# 
# 3star_OpenDocument/schedule.ods: 2star_Excel/schedule.xls
# 	soffice --headless --convert-to ods --outdir "$$(dirname "$@")" "$<"

# 3.5star_CSV/schedule.csv: 3star_OpenDocument/schedule.ods
# 	soffice --headless --convert-to csv --outdir "$$(dirname "$@")" "$<"

$(HOMEPAGE)/index.html: README.org
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
