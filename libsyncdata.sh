#!/bin/bash
DIR="/home/rialfi/saime"
if test -e $DIR/check/info_$(date -d yesterday +%Y%m%d); then
	result=$(head -n 1 info_$(date -dyesterday +%Y%m%d))
	if [ $result -eq 0 ]; then
		exit 0
	else
		lftp -u cgp:NpkQsCtfnb -p 21 ftp.saime.gob.ve << EOF
	        cd Cedulado/
        	mget *
        	quit
        	EOF

        	resumen=$(ls -l Cedulado_CNE_$(date -d yesterday +%Y%m%d)*.send | wc -l)
        	if [ $resumen -eq 0 ]; then
                	echo "Error en  descarga o no hay actualizaciones en el dia "$(date -d yesterday +%d-%m-%Y) | mail -s  "Descarga de archivos SAIME" cramirez@rialfi.com 
	                echo "Error en  descarga o no hay actualizaciones en el dia "$(date -d yesterday +%d-%m-%Y) >> /var/log/libsyncdata.log
        	        echo $? > $DIR/check/info_$(date -d yesterday +%Y%m%d)
        	else
                	scp -r Cedulado_CNE_$(date -d yesterday +%Y%m%d)*.send rialfi@192.168.0.101:/home/rialfi/saime/
                	echo "Se descargaron "$resumen" directorios comprimidos de la fecha "$(date -d yesterday +%d-%m-%Y) | mail -s "Descarga de archivos SAIME" cramirez@rialfi.com
                	echo "Se descargaron "$resumen" directorios comprimidos de la fecha "$(date -d yesterday +%d-%m-%Y) | >> /var/log/libsyncdata.info
                	echo $? > $DIR/check/info_$(date -d yesterday +%Y%m%d)
        	fi
        	find . -name "*.send" -exec rm {} \;
	fi
else
	touch $DIR/info_$(date -d yesterday +%Y%m%d)
	lftp -u cgp:NpkQsCtfnb -p 21 ftp.saime.gob.ve << EOF
	cd Cedulado/
	mget *
	quit
	EOF

	resumen=$(ls -l Cedulado_CNE_$(date -d yesterday +%Y%m%d)*.send | wc -l)
	if [ $resumen -eq 0 ]; then
		echo "Error en  descarga o no hay actualizaciones en el dia "$(date -d yesterday +%d-%m-%Y) | mail -s  "Descarga de archivos SAIME" cramirez@rialfi.com	
		echo "Error en  descarga o no hay actualizaciones en el dia "$(date -d yesterday +%d-%m-%Y) >> /var/log/libsyncdata.log
		echo $? > $DIR/check/info_$(date -d yesterday +%Y%m%d)
	else
		scp -r Cedulado_CNE_$(date -d yesterday +%Y%m%d)*.send rialfi@192.168.0.101:/home/rialfi/saime/
		echo "Se descargaron "$resumen" directorios comprimidos de la fecha "$(date -d yesterday +%d-%m-%Y) | mail -s "Descarga de archivos SAIME" cramirez@rialfi.com
		echo "Se descargaron "$resumen" directorios comprimidos de la fecha "$(date -d yesterday +%d-%m-%Y) >> /var/log/libsyncdata.info
		echo $? > $DIR/check/info_$(date -d yesterday +%Y%m%d)
	fi
	find . -name "*.send" -exec rm {} \;
fi
