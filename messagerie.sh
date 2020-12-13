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

for l in $(cat /etc/passwd | grep "/bin/bash" |  awk -F: '{ print $1}'); do
    listUser+="$l \"\" false "
    if [ ! -d "/messagerie/messages_$l" ]; then
        dossier="/messagerie/messages_$l"
        mkdir $dossier
    fi
done

while [ ! "$mode" = "Quitter" ]; do
    mode=$(dialog --title "Messagerie" --menu "Que voulez vous faire ?" 20 60 15 "Voir ses messages" "" "Envoyer un nouveau message" "" "Quitter" "" 2>&1 >/dev/tty)
    if [ "$mode" = "Envoyer un nouveau message" ]; then
        destinataires=$(dialog --title "Messagerie" --checklist "A qui voulez vous envoyer un message ?" 20 60 15 \
                $listUser 2>&1 >/dev/tty)
        if [ "$?" = "1" ]; then
            continue
        fi        
        while [ -z ${destinataires[@]} ]; do
            dialog --stdout --title "Messagerie" --msgbox "Veuillez entrer au moins un destinataire." 5 60 2>&1 >/dev/tty
            destinataires=$(dialog --title "Messagerie" --checklist "A qui voulez vous envoyer un message ?" 20 60 15 \
                $listUser 2>&1 >/dev/tty)
            if [ "$?" = "1" ]; then
                continue
            fi       
        done

        sujet=$(dialog --title "Messagerie" --inputbox "Quel est le sujet de votre message ?" 20 60 2>&1 >/dev/tty) 
        if [ "$?" = "1" ]; then
            continue
        fi  
        while [ -z $sujet ]; do
            dialog --title "Messagerie" --msgbox "Veuillez entrer un sujet." 5 60 2>&1 >/dev/tty
            sujet=$(dialog --title "Messagerie" --inputbox "Quel est le sujet de votre message ?" 20 60 2>&1 >/dev/tty)
            if [ "$?" = "1" ]; then
                continue
            fi  
        done
        sujet=$(echo $sujet | sed -e "s/ /_/g")
        contenu=$(dialog --title "Messagerie" --editbox "/messagerie/test" 20 60 2>&1 >/dev/tty)
        if [ "$?" = "1" ]; then
            continue
        fi  
        while [ -z $contenu ]; do
            dialog --title "Messagerie" --msgbox "Veuillez entrer un message." 5 60 2>&1 >/dev/tty
            contenu=$(dialog --title "Messagerie" --editbox "/messagerie/test" 20 60 2>&1 >/dev/tty)
            if [ "$?" = "1" ]; then
                continue
            fi  
        done
        for variable in ${destinataires[@]}; do
            echo -e "Destinataire(s) : $destinataires\n\nSujet : $sujet\n\nContenu : $contenu" > "/messagerie/messages_$variable/$sujet-_De_:_$(whoami)"
        done
    else
        if [ "$mode" = "Voir ses messages" ]; then
            options=""
            cd "/messagerie/messages_$(whoami)/"
            for file in $(ls *); do
                options+="$file \"\" "
            done
            if [ "$options" != "" ]; then
                messageALire=$(dialog --title "Messagerie" --menu "Choissiez un message" 20 60 10 $options 2>&1 >/dev/tty)
                queFaire=$(dialog --title "Messagerie" --menu "Que voulez vous faire ?" 20 60 15 "Lire le message" "" "Supprimer le message" "" 2>&1 >/dev/tty)
                if [ "$?" = "1" ]; then
                    continue
                fi 
                if [ "$queFaire" = "Lire le message" ]; then
                    if [ ${messageALire#*.} = "tar" ]; then
                        fichier=$(tar -xvf $messageALire)
                        dialog --title "Messagerie" --textbox "/messagerie/messages_$(whoami)/$fichier" 20 60 2>&1 >/dev/tty
                        rm $fichier
                    else 
                        dialog --title "Messagerie" --textbox "/messagerie/messages_$(whoami)/$messageALire" 20 60 2>&1 >/dev/tty
                    fi  
                else
                    if [ "$queFaire" = "Supprimer le message" ]; then
                        rm "/messagerie/messages_$(whoami)/$messageALire"
                    fi
                fi
            else
                dialog --title "Messagerie" --msgbox "Vous n'avez aucun message." 5 60 2>&1 >/dev/tty
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