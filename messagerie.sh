#!/bin/bash

if [ ! -d "/messagerie/" ]; then
    sudo mkdir "/messagerie/"
    sudo touch "/messagerie/test"
    sudo chmod 777 "/messagerie/"
fi   

cd "/messagerie/messages_$(whoami)/"

for file in $( find /messagerie/messages_$(whoami)/ -type f -ctime +1 ! -name "*.tar*"); do
    file2=$(echo $file | sed -e "s/\/messagerie\/messages_$(whoami)\///g")
	tar -cvf $file.tar $file2
	rm $file2
done

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
        sujet=$(echo $sujet | sed -e "s/ /_/g")
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
            if [ "$options" != "" ]; then
                messageALire=$(dialog --stdout --title "Messagerie" --menu "Choissiez un message" 20 60 10 $options)
                queFaire=$(dialog --stdout --title "Messagerie" --menu "Que voulez vous faire ?" 20 60 15 "Lire le message" "" "Supprimer le message" "")
                if [ "$queFaire" = "Lire le message" ]; then
                    if [ ${messageALire#*.} = "tar" ]; then
                        fichier=$(tar -xvf $messageALire)
                        dialog --stdout --title "Messagerie" --textbox "/messagerie/messages_$(whoami)/$fichier" 20 60
                        rm $fichier
                    else 
                        dialog --stdout --title "Messagerie" --textbox "/messagerie/messages_$(whoami)/$messageALire" 20 60
                    fi  
                else
                    if [ "$queFaire" = "Supprimer le message" ]; then
                        rm "/messagerie/messages_$(whoami)/$messageALire"
                    fi
                fi
            fi
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