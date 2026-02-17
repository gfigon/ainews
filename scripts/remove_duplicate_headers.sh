#!/bin/bash
POSTS_DIR="/home/skutek/projekty/ainews/posts"

# Przetwarzanie plików index.qmd
for qmd in $(find "$POSTS_DIR" -name "index.qmd"); do
  # Usuwamy pierwszą linię zaczynającą się od # (H1), która znajduje się poza blokiem YAML.
  # Ponieważ YAML kończy się linią ---, szukamy nagłówka poniżej tej linii.
  
  # Używamy sed, aby usunąć pierwsze wystąpienie "# " po drugim wystąpieniu "---"
  # (Konstrukcja: od drugiego ogranicznika YAML do końca pliku, usuń pierwszy nagłówek #)
  sed -i '0,/^---$/b; /---/,$ { /# .*/ { s/# .*//; :a; n; ba } }' "$qmd"
  
  # Powyższy sed jest skomplikowany. Użyjemy prostszego podejścia: 
  # znajdź numer linii drugiego "---" i usuń pierwszy nagłówek # pod nim.
  line_num=$(grep -n "^---$" "$qmd" | sed -n '2p' | cut -d: -f1)
  if [ ! -z "$line_num" ]; then
    # Usuwamy nagłówek # bezpośrednio pod frontmatterem (zazwyczaj to ten dubel)
    # i dodatkowe puste linie powstałe po usunięciu
    sed -i "$((line_num+1)),$((line_num+10)) { /^# /d }" "$qmd"
  fi
done

echo "Zdublowane nagłówki H1 zostały usunięte."
