LATEXMK=latexmk

MAINDOCUMENT = Thesis
SOURCES=$(MAINDOCUMENT).tex Makefile


all: latexmake

verbose:
	$(LATEXMK) --verbose

latexmake:
	$(LATEXMK)

clean:
	$(LATEXMK) -c $(MAINDOCUMENT).tex
	rm -f *.aux
	rm -f *.lol
	rm -f Chapters/*.aux
	rm -f FrontBackmatter/*.aux
	rm -f *.bak
	rm -f Chapters/*.bak
	rm -f Chapters/*.aux
	rm -f FrontBackmatter/*.bak

lua:
	lualatex  -shell-escape $(MAINDOCUMENT).tex

glossaries:
	makeglossaries $(MAINDOCUMENT)

.PHONY: clean latexmake lua glossaries
