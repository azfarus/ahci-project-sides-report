#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# compile.sh – Build the report or slides with latexmk.
#
# Usage:
#   ./compile.sh report   – compile report/hci-assignment-1.tex
#   ./compile.sh slides   – compile slides/presentation.tex
#   ./compile.sh all      – compile both
#   ./compile.sh clean    – remove all build artefacts
#
# Auxiliary / intermediate files are placed in build/<target>/
# so that source directories stay clean.
# ──────────────────────────────────────────────────────────
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── helpers ──────────────────────────────────────────────
usage() {
  echo "Usage: $0 {report|slides|all|clean}"
  exit 1
}

compile_target() {
  local target="$1"       # "report" or "slides"
  local tex_file="$2"     # relative path from ROOT_DIR
  local src_dir            # directory containing the .tex
  src_dir="$(dirname "$tex_file")"

  local build_dir="${ROOT_DIR}/build/${target}"
  mkdir -p "$build_dir"

  echo "━━━ Compiling ${target} ━━━"
  echo "  Source : ${ROOT_DIR}/${tex_file}"
  echo "  Build  : ${build_dir}"
  echo ""

  # Run latexmk from the source directory so that \includegraphics
  # and \bibliography with relative paths resolve correctly.
  # -auxdir  → put .aux, .log, .bbl, … in the build directory
  # -outdir  → put the final PDF in the build directory too
  latexmk -pdf \
          -pdflatex="pdflatex -interaction=nonstopmode -file-line-error %O %S" \
          -auxdir="$build_dir" \
          -outdir="$build_dir" \
          -cd \
          "${ROOT_DIR}/${tex_file}"

  # Copy the final PDF back into the source directory for convenience
  local pdf_name
  pdf_name="$(basename "${tex_file}" .tex).pdf"
  cp "${build_dir}/${pdf_name}" "${ROOT_DIR}/${src_dir}/${pdf_name}"

  echo ""
  echo "  ✓ PDF ready → ${src_dir}/${pdf_name}"
  echo ""
}

clean_all() {
  echo "━━━ Cleaning build artefacts ━━━"
  rm -rf "${ROOT_DIR}/build"
  echo "  ✓ build/ removed"
}

# ── main ─────────────────────────────────────────────────
[[ $# -lt 1 ]] && usage

case "$1" in
  report)
    compile_target "report" "report/hci-assignment-1.tex"
    ;;
  slides)
    compile_target "slides" "slides/presentation.tex"
    ;;
  all)
    compile_target "report" "report/hci-assignment-1.tex"
    compile_target "slides" "slides/presentation.tex"
    ;;
  clean)
    clean_all
    ;;
  *)
    usage
    ;;
esac
