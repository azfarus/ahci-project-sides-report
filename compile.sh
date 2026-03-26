#!/usr/bin/bash


current_dir=$(pwd)
cd $1

pdflatex -interaction=nonstopmode *.tex

# Run biber for bibliography
# biber *.bcf
bibtex *.aux

# Run pdflatex twice more with nonstopmode for cross-references
pdflatex -interaction=nonstopmode *.tex
pdflatex -interaction=nonstopmode *.tex
rm -r *.aux *.bcf *.log *.blg *.nav *.out *.xml *.snm *.toc *.bbl
cd "$current_dir"