#!/bin/bash

# Base URL
BASE_URL="https://mangamoins.shaeishu.co/files/scans"

# Base path local
BASE_PATH="/media/nas/video/ebook/Manga/One Piece/MangaMoins"

# User agent pour simuler un navigateur
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Fonction pour telecharger un chapitre
download_chapter() {
    local version=$1   # OP ou OPC
    local chap=$2      # numero de chapitre, ex: 1158

    # Dossier cible
    local target_dir="$BASE_PATH/$version/$chap"

    # Skip si dossier existe et non vide
    if [ -d "$target_dir" ] && [ "$(ls -A "$target_dir")" ]; then
        echo "Dossier $target_dir existe et n est pas vide, skip."
        return 0
    fi

    mkdir -p "$target_dir"

    local found_any=0

    # On suppose que les images commencent a 01 et vont jusqu a 99 max
    for i in $(seq -w 1 99); do
        # URL possible (majuscule et minuscule)
        URL_UPPER="$BASE_URL/$version$chap/$i.png"
        URL_LOWER="$BASE_URL/$(echo $version | tr  [:upper:]   [:lower:] )$chap/$i.png"

        echo "Tentative telechargement: $i.png pour $version$chap"

        # Telechargement
        curl -A "$USER_AGENT" -f -s -o "$target_dir/$i.png" "$URL_UPPER" || \
        curl -A "$USER_AGENT" -f -s -o "$target_dir/$i.png" "$URL_LOWER"

        if [ ! -f "$target_dir/$i.png" ]; then
            # Si aucune image n a ete trouvee pour le premier fichier, on considere que le chapitre n existe pas
            if [ $i -eq 01 ]; then
                echo "Chapitre $chap version $version non disponible."
                return 1
            else
                echo "Fin du chapitre $chap pour $version."
                break
            fi
        else
            echo "Image $i.png telechargee"
            found_any=1
        fi
    done

    return 0
}

# Premier chapitre
chapitre=1037

while true; do
    echo "Telechargement chapitre $chapitre"

    # On commence par OP (noir et blanc)
    download_chapter "OP" "$chapitre"
    if [ $? -ne 0 ]; then
        echo "Chapitre $chapitre OP non disponible. Arret du script."
        break
    fi

    # Puis OPC (couleur)
    download_chapter "OPC" "$chapitre"

    # Passer au chapitre suivant
    chapitre=$((chapitre+1))
done
