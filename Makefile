LATEXMK=latexmk

MAINDOCUMENT = Thesis
SOURCES=$(MAINDOCUMENT).tex Makefile

UMLFILES=$(wildcard gfx/uml/*.plantuml)

all: uml latexmake

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
	rm -f gfx/uml/*.png

lua:
	lualatex  -shell-escape $(MAINDOCUMENT).tex

glossaries:
	makeglossaries $(MAINDOCUMENT)

uml:
	java -jar /opt/local/bin/plantuml.jar -v $(UMLFILES) 
.PHONY: clean latexmake lua glossaries uml
