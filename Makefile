######################################################################
# Makefile
#
# Makefile for LaTeX projects
######################################################################

BASE = main

PAPERS = $(BASE)
BIBS = $(wildcard *.orig.bib)
SRCS = $(wildcard *.tex) $(wildcard *.sty) $(BIBS:%.orig.bib=%.short.bib)

.PHONY: html pdf all

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

# Generate TR TeX
%.tr.tex: %.tex
	sed 's/\\TRfalse/\\TRtrue/' $< >$@

# Generate Posting Version TeX
%.post.tex: %.tex
	sed 's/\\Postingfalse/\\Postingtrue/' $< >$@

# Generate PDF
%.pdf: %.tex
	latexmk -pdf -use-make $<

# Generate short bib
%.short.bib: %.orig.bib
	sed -e 's/@string{SHORT/@string{/' \
            -e 's/^[ 	]*[Ee]ditor/OPTeditor/' \
            -e 's/^[ 	]*[Mm]onth/OPTmonth/' \
            -e 's/^[ 	]*[Pp]publisher/OPTpublisher/' \
            -e 's/^[ 	]*[Aa]ddress/OPTaddress/' \
            -e 's/^[ 	]*[Ii]sbn/OPTisbn/' \
            -e 's/^[ 	]*[Ii]ssn/OPTissn/' \
            -e 's/^[ 	]*[Uu]rl/OPTurl/' \
            -e 's/^[ 	]*[Dd]oi/OPTdoi/' \
            -e 's/^[ 	]*[Pp]ages/OPTpages/' \
            -e 's/^[ 	]*[Cc]rossref/OPTcrossref/' \
            -e 's/^[ 	]*[Ss]eries/OPTseries/' \
            $< > $@

%.txt: %.tex
	cat $< | detex | sed 's/---/--/g' > $@
