HOMEPAGE = homepage
NAMESPACE = http://purl.org/net/wiss2014/
SYNC_FILES = org-info.js bootstrap.min.css images
DEMO_FILES = 1star_PDF/schedule.pdf \
	2star_Excel/schedule.xls \
	3star_OpenDocument/schedule.ods \
	3.5star_CSV/presenters.csv \
	3.5star_CSV/schedule.csv \
	3.5star_CSV/schedule-alt.csv \
	4star_CSV/presenters.csv \
	4star_CSV/schedule.csv \
	4.5star_CSV/presenters.csv \
	4.5star_CSV/schedule.csv \
	4.5star_CSV/vocab.csv \
	4.5star_CSV/more/presenters.csv \
	4.5star_CSV/more/schedule.csv \
	5star_RDF/presenters.rdf \
	5star_RDF/schedule.rdf \
	5star_RDF/vocab.rdf \
	5star_RDF/data.ttl
DEPLOY_FILES = 4.5star_CSV/more/presenters.csv \
	4.5star_CSV/more/schedule.csv \
	4.5star_CSV/vocab.csv \
	5star_RDF/presenters.rdf \
	5star_RDF/schedule.rdf \
	5star_RDF/vocab.rdf \
	deploy/.htaccess
DEPLOY_DIRS = schedule presenters vocab

.sync: $(HOMEPAGE)/.sync $(HOMEPAGE)/index.html
	(cd $(HOMEPAGE) ; \
		git commit -m "regenerated" index.html ; \
		git push) ; \
	touch $@

$(HOMEPAGE)/.sync: $(DEMO_FILES) $(SYNC_FILES)
	rsync -avR $(DEMO_FILES) $(SYNC_FILES) homepage/ ; \
	touch $@

.deploy: $(DEPLOY_FILES)
	STAGE=$$(mktemp -d) ; \
	cp -av $(DEPLOY_FILES) $$STAGE ; \
	chmod 755 $$STAGE ; \
	chmod 644 $$STAGE/* ; \
	( cd $$STAGE ; \
		for i in $(DEPLOY_DIRS) ; \
		do \
			mkdir -v $$i ; \
			mv -v $$i.rdf $$i/index.rdf ; \
			mv -v $$i.csv $$i/index.csv ; \
		done ; \
		chmod 755 $(DEPLOY_DIRS) ) ; \
	rsync -av $$STAGE/ iai:public_html/wiss2014 ; \
	rm -rf $$STAGE ; \
	touch $@

# exports to "flat XML", which we don't want
# 
# 3star_OpenDocument/schedule.ods: 2star_Excel/schedule.xls
# 	soffice --headless --convert-to ods --outdir "$$(dirname "$@")" "$<"

# 3.5star_CSV/schedule.csv: 3star_OpenDocument/schedule.ods
# 	soffice --headless --convert-to csv --outdir "$$(dirname "$@")" "$<"

%.rdf: %.nt
	rapper -i ntriples -o rdfxml-abbrev $< > $@

# TODO merge the following into one rule
5star_RDF/schedule.nt: 5star_RDF/data.nt
	grep '^<$(NAMESPACE)schedule/' $< > $@

5star_RDF/presenters.nt: 5star_RDF/data.nt
	grep '^<$(NAMESPACE)presenters/' $< > $@

5star_RDF/vocab.nt: 5star_RDF/data.nt
	grep '^<$(NAMESPACE)vocab/' $< > $@

%.nt: %.ttl
	rapper -i turtle -o ntriples $< > $@

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
