#!/bin/bash
# Kompilierung der Projektdokumentation unter Linux using Docker

set -e

# Ask if PlantUML diagrams should be compiled
read -p "Sollen die PlantUML Diagramme kompiliert werden (y/n)? " answer
if [[ $answer == "y" ]]; then
    echo "Die Diagramme werden kompiliert"
    echo "Diagramme werden in SVG umgewandelt"
    for file in PlantUML/*.puml; do
        [ -e "$file" ] || continue
        java -jar plantuml.jar -charset UTF-8 -svg "$file"
    done

    echo "Diagramme wurden erfolgreich in SVG umgewandelt"
    echo "Diagramme werden in PDF umgewandelt"
    for svg in PlantUML/*.svg; do
        [ -e "$svg" ] || continue
        pdf="Anhang/$(basename "${svg%.*}").pdf"
        inkscape --export-filename="$pdf" "$svg"
    done

    echo "Diagramme wurden erfolgreich in PDF umgewandelt"
    echo "Diagramme als SVG werden geloescht"
    rm -f PlantUML/*.svg
    echo "Diagramme als SVG wurden erfolgreich geloescht"
else
    echo "Die Diagramme werden nicht kompiliert"
fi

# Compile Projektdokumentation.tex
for i in 1 2; do
    echo "Projektdokumentation.tex wird kompiliert"
    docker run -i --rm -w /data -v "$(pwd):/data" texlive/texlive:latest latexmk "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-pdf" "-outdir=./" "Projektdokumentation" -f
    echo "Projektdokumentation.tex wurde kompiliert"
done

# Ask to open PDF
read -p "Soll die Datei geoeffnet werden (y/n)? " open
if [[ $open == "y" ]]; then
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open ./Projektdokumentation.pdf &
    elif command -v open >/dev/null 2>&1; then
        open ./Projektdokumentation.pdf &
    else
        echo "Kein passender PDF-Viewer gefunden"
    fi
    echo "Datei wurde geoeffnet"
else
    echo "Script wird beendet"
fi
