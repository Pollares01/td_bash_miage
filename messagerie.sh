#!/bin/bash

if [ ! -d "/messagerie/" ]; then
    mkdir "/messagerie/"
    touch "/messagerie/test"
    chmod 777 "/messagerie/"
fi   

while [ ! "$mode" = "Quitter" ]; do
    mode=$(dialog --stdout --title "Messagerie" --menu "Que voulez vous faire ?" 20 60 15 "Lire ses messages" "" "Envoyer un nouveau message" "" "Quitter" "")
    if [ "$mode" = "Envoyer un nouveau message" ]; then
        destinataires=$(dialog --stdout --title "Messagerie" --checklist "A qui voulez vous envoyer un message ?" 20 60 15 \
                "paul" "" false "paul2" "" false)
        if [ "$?" = "1" ]; then
            continue
        fi        
        while [ -z ${destinataires[@]} ]; do
            dialog --stdout --title "Messagerie" --msgbox "Veuillez entrer au moins un destinataire." 5 60
            destinataires=$(dialog --stdout --title "Messagerie" --checklist "A qui voulez vous envoyer un message ?" 20 60 15 \
                "paul" "" false "paul2" "" false)
            if [ "$?" = "1" ]; then
                continue
            fi       
        done
        for variable in ${destinataires[@]}; do
            if [ ! -d "/messagerie/messages_$variable" ]; then
                dossier="/messagerie/messages_$variable"
                mkdir $dossier
            fi
        done
        sujet=$(dialog --stdout --title "Messagerie" --inputbox "Quel est le sujet de votre message ?" 20 60) 
        if [ "$?" = "1" ]; then
            continue
        fi  
        while [ -z $sujet ]; do
            dialog --stdout --title "Messagerie" --msgbox "Veuillez entrer un sujet." 5 60
            sujet=$(dialog --stdout --title "Messagerie" --inputbox "Quel est le sujet de votre message ?" 20 60)
            if [ "$?" = "1" ]; then
                continue
            fi  
        done
        contenu=$(dialog --stdout --title "Messagerie" --editbox "/messagerie/test" 20 60)
        if [ "$?" = "1" ]; then
            continue
        fi  
        while [ -z $contenu ]; do
            dialog --stdout --title "Messagerie" --msgbox "Veuillez entrer un message." 5 60
            contenu=$(dialog --stdout --title "Messagerie" --editbox "/messagerie/test" 20 60)
            if [ "$?" = "1" ]; then
                continue
            fi  
        done
        for variable in ${destinataires[@]}; do
            echo -e "Destinataire(s) : $destinataires\n\nSujet : $sujet\n\nContenu : $contenu" > "/messagerie/messages_$variable/$sujet-_De_:_$(whoami)"
        done
    else
        if [ "$mode" = "Lire ses messages" ]; then
            options=""
            cd "/messagerie/messages_$(whoami)/"
            for file in $(ls *); do
                options+="$file \"\" "
            done
            messageALire=$(dialog --stdout --title "Messagerie" --menu "Choissiez un message" 20 60 10 $options)
            if [ "$?" = "1" ]; then
                continue
            fi  
            dialog --stdout --title "Messagerie" --textbox "/messagerie/messages_$(whoami)/$messageALire" 20 60
            clear
        else
            if [ "$mode" = "Quitter" ]; then
                clear
                exit
            fi
        fi
    fi
done
clear