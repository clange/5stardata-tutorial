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
