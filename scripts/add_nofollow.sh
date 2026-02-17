#!/bin/bash
POSTS_DIR="/home/skutek/projekty/ainews/posts"

for qmd in $(find "$POSTS_DIR" -name "index.qmd"); do
  # Krok 1: Dodaj {rel="nofollow"} do WSZYSTKICH linków z http/https
  # Znajdź ](http...)] i zamień na ](http...)]{rel="nofollow"}
  
  # Używamy prostego podejścia: dodaj na końcu każdego linku (przed ostatnim ))
  # Zakładamy format: [text](url)
  
  # Najpierw dodajmy nofollow do wszystkich linków
  sed -i 's/\](\(https\{0,1\}:\/\/[^)]*\))/\1){rel="nofollow"}/g' "$qmd"
  
  # Krok 2: Przywróć linki wewnętrzne (roboaidigest.com) - usuń nofollow
  sed -i 's/roboaidigest\.com){rel="nofollow"}/roboaidigest.com)/g' "$qmd"
  
  # Krok 3: Przywróć również jeśli są to linki z rel= już (żeby nie zduplikować)
  sed -i 's/{rel="nofollow"}{rel="nofollow"}/{rel="nofollow"}/g' "$qmd"
  
done

echo "Done!"
