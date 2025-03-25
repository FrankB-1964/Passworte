#!/bin/bash

# Passwortgenerator mit Zenity-Oberfläche
# Unterstützt verschiedene Komplexitätsstufen

# Funktion zur Passwortgenerierung
generate_password() {
    local length=$1
    local complexity=$2
    
    case $complexity in
        "Einfach (nur Buchstaben)")
            tr -dc 'a-zA-Z' < /dev/urandom | head -c "$length"
            ;;
        "Standard (Buchstaben und Zahlen)")
            tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
            ;;
        "Komplex (Buchstaben, Zahlen, Sonderzeichen)")
            tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c "$length"
            ;;
        "Sicher (inkl. Unicode-Sonderzeichen)")
            tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=[]{}|;:,.<>?¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ' < /dev/urandom | head -c "$length"
            ;;
        *)
            tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
            ;;
    esac
}

# Hauptdialog
while true; do
    # Passwortlänge auswählen
    length=$(zenity --scale \
        --title="Passwortgenerator" \
        --text="Wählen Sie die Länge des Passworts:" \
        --min-value=8 \
        --max-value=64 \
        --value=12 \
        --step=1 2>/dev/null)
    
    # Abbrechen überprüfen
    if [ $? -ne 0 ]; then
        zenity --info --text="Vorgang abgebrochen" --title="Info"
        exit 0
    fi
    
    # Komplexitätsstufe auswählen
    complexity=$(zenity --list \
        --title="Passwortkomplexität" \
        --text="Wählen Sie die Komplexitätsstufe:" \
        --column="Stufe" \
        "Einfach (nur Buchstaben)" \
        "Standard (Buchstaben und Zahlen)" \
        "Komplex (Buchstaben, Zahlen, Sonderzeichen)" \
        "Sicher (inkl. Unicode-Sonderzeichen)" \
        --height=200 2>/dev/null)
    
    # Abbrechen überprüfen
    if [ $? -ne 0 ]; then
        zenity --info --text="Vorgang abgebrochen" --title="Info"
        exit 0
    fi
    
    # Passwort generieren
    password=$(generate_password "$length" "$complexity")
    
    # Ergebnis anzeigen
    zenity --info \
        --title="Ihr generiertes Passwort" \
        --text="Passwortlänge: $length Zeichen\nKomplexität: $complexity\n\nIhr Passwort:\n\n<span font='monospace 14'><b>$password</b></span>" \
        --ok-label="Neues Passwort" \
        --extra-button="Kopieren" \
        --extra-button="Beenden" 2>/dev/null
    
    case $? in
        1) # Beenden-Knopf
            exit 0
            ;;
        0) # Neues Passwort
            continue
            ;;
        *) # Kopieren-Knopf
            echo -n "$password" | xclip -selection clipboard
            zenity --notification --text="Passwort wurde in die Zwischenablage kopiert!"
            ;;
    esac
done
