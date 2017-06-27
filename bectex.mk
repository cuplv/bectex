######################################################################
# Makefile
#
# Makefile for LaTeX projects
######################################################################

BIBS = $(wildcard *.orig.bib)
SRCS = $(wildcard *.tex) $(wildcard *.sty) $(BIBS:%.orig.bib=%.short.bib)

.PHONY: html pdf all init cleandeps clean cleanall

all: pdf
pdf: ${PAPERS:%=%.pdf}
html: ${PAPERS:%=%/index.html}

${PAPERS:%=%.pdf}: ${SRCS}

cleandeps:
	rm -f $(BIBS:%.orig.bib=%.short.bib)
clean: cleandeps
	latexmk -c
cleanall: cleandeps
	latexmk -C
	
# Symlink bectex files to this directory
init:
	ln -s bectex/* .

# Generate TR TeX
%.tr.tex: %.tex
	sed 's/\\TRfalse/\\TRtrue/' $< >$@

# Generate Posting Version TeX
%.post.tex: %.tex
	sed 's/\\Postingfalse/\\Postingtrue/' $< >$@

# Generate PDF
%.pdf: %.tex
	latexmk -pdf -use-make $<

# Detex a .tex file
%.txt: %.tex
	cat $< | detex | sed 's/---/--/g' > $@
