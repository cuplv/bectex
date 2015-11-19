######################################################################
# Makefile
#
# Makefile for LaTeX projects
######################################################################

BASE = paper

PAPERS = $(BASE)
BIBS = $(wildcard *.orig.bib)
SRCS = $(wildcard *.tex) $(wildcard *.sty) $(BIBS:%.orig.bib=%.short.bib)

GS = gs
#GS = gswin32c

GS_OPTS = -q -dNOPAUSE -dBATCH -sDEVICE=bbox
DVIPS_OPTS = -Ppdf -Pcmz -Pamz -t letter -D 600 -G0
#DVIPS_OPTS = -t letter -z -P pdf
DVIPDFM_OPTS = -p letter
PS2PDF_OPTS = 

.PHONY: html dvi ps pdf all figeps figpdf

all: pdf
dvi: ${PAPERS:%=%.dvi}
${PAPERS:%=%.dvi}: ${SRCS} ${FIGURES:%=%.eps}
ps: ${PAPERS:%=%.ps}
pdf: ${PAPERS:%=%.pdf}
${PAPERS:%=%.pdf}: ${SRCS} ${FIGURES:%=%.pdf}
html: ${PAPERS:%=%/index.html}

clean:
	rm -rf ${PAPERS} ${PAPERS:%=%.dvi} ${PAPERS:%=%.ps} ${PAPERS:%=%.pdf} \
               auto builddate.tex *.aux *.toc *.lof *.lot *.log *.bbl *.blg \
               *.pst.* *.tmp *~ *.out *.thm *.detex *.tr.tex \
               *.short.bib

# Generate TR TeX
%.tr.tex: %.tex
	sed 's/\\TRfalse/\\TRtrue/' $< >$@

# Generate Posting Version TeX
%.post.tex: %.tex
	sed 's/\\Postingfalse/\\Postingtrue/' $< >$@

# Generate DVI
#   run once, then re-run until it's happy
#   input redirected from /dev/null is like hitting ^C at first error
%.dvi: %.tex
	${MAKE} figeps
	(echo -n "\def\builddate{"; date; echo "}") >builddate.tex
	if latex ${<} </dev/null; then \
		true; \
	else \
		stat=$$?; touch ${<:%.tex=%.dvi}; exit $$stat; \
	fi
	if grep -q "\\citation" ${<:%.tex=%.aux}; then \
		bibtex ${<:%.tex=%}; \
	fi
	while grep -q "Rerun to get" ${<:%.tex=%.log}; do \
		if latex ${<} </dev/null; then \
			true; \
		else \
			stat=$$?; touch ${<:%.tex=%.dvi}; exit $$stat; \
		fi; \
	done

# Generate PS
%.ps: %.dvi
	dvips ${DVIPS_OPTS} -o ${<:%.dvi=%.ps} $<

# Generate PDF
%.pdf: %.tex
	${MAKE} figpdf
	# Remove the .aux file because pdflatex wants it different
	rm -f ${<:%.tex=%.aux} ${<:%.tex=%.thm}
	(echo -n "\def\builddate{"; date; echo "}") >builddate.tex
	if pdflatex ${<} </dev/null; then \
		true; \
	else \
		stat=$$?; touch ${<:%.tex=%.pdf}; exit $$stat; \
	fi
	if grep -q "\\citation" ${<:%.tex=%.aux}; then \
		bibtex ${<:%.tex=%}; \
	fi
	while grep -q "Rerun to get" ${<:%.tex=%.log}; do \
		if pdflatex ${<} </dev/null; then \
			true; \
		else \
			stat=$$?; touch ${<:%.tex=%.pdf}; exit $$stat; \
		fi; \
	done

# Generate PDF (using dvipdfm)
#%.pdf: %.dvi
#	dvipdfm ${DVIPDFM_OPTS} $<

# Generate PDF (using ps2pdf)
#%.pdf: %.ps
#	ps2pdf ${PS2PDF_OPTS} $<

# Generate short bib
%.short.bib: %.orig.bib
	#sed -e 's/@string{SHORT/@string{/'
	sed -e 's/@string{SHORT/@string{/' \
            -e 's/[Ee]ditor/OPTeditor/' \
            -e 's/[Mm]onth/OPTmonth/' \
            -e 's/[Pp]ublisher/OPTpublisher/' \
            -e 's/[Aa]ddress/OPTaddress/' \
            -e 's/[Ii]sbn/OPTisbn/' \
            -e 's/[Ii]ssn/OPTissn/' \
            -e 's/[Uu]rl/OPTurl/' \
            -e 's/^[ 	]*[Dd]oi/OPTdoi/' \
            -e 's/[Pp]ages/OPTpages/' \
            -e 's/[Cc]rossref/OPTcrossref/' \
            -e 's/[Ss]eries/OPTseries/' \
            $< > $@

%.txt: %.tex
	cat $< | detex | sed 's/---/--/g' > $@
