for file in $( find /home/corentin/monDossier -type f -ctime +1 ! -name "*.tar*"); do 	
	tar -cvf $file.tar $file
	rm $file
done
