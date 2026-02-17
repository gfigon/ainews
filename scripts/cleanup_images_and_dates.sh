#!/bin/bash
POSTS_DIR="/home/skutek/projekty/ainews/posts"

# 1. Usuwanie fizycznych plików obrazków
find "$POSTS_DIR" -name "image.svg" -delete
find "$POSTS_DIR" -name "image.jpg" -delete

# 2. Przetwarzanie plików index.qmd
for qmd in $(find "$POSTS_DIR" -name "index.qmd"); do
  # Usuwanie linii z obrazkiem
  sed -i '/^image:/d' "$qmd"
  
  # Aktualizacja daty na format z godziną
  # Wyciągamy datę (YYYY-MM-DD)
  current_date=$(grep "^date:" "$qmd" | sed 's/date: //; s/"//g')
  
  # Jeśli data nie ma jeszcze godziny, dodajemy domyślnie 08:00
  if [[ $current_date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    # Dla dzisiejszych postów (2026-02-17) możemy spróbować przypisać godziny z harmonogramu (uproszczone)
    # Wyszukujemy po fragmencie ścieżki (slug)
    if [[ "$qmd" == *"saaspocalypse"* ]]; then hour="08:00";
    elif [[ "$qmd" == *"qwen3-5"* ]]; then hour="08:45";
    elif [[ "$qmd" == *"microsoft-mai-1"* ]]; then hour="10:15";
    else hour="08:00"; fi
    
    sed -i "s/^date:.*/date: \"$current_date $hour\"/" "$qmd"
  fi
done

echo "Zakończono czyszczenie obrazków i aktualizację dat."
