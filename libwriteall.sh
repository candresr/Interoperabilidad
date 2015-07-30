#!/bin/bash
DIR="/home/rialfi/saime"
file=$(head -n 1 $DIR/check/info_$(date -d yesterday +%Y%m%d))
if [ $result -eq 0 ]; then

	if test -e $DIR/Cedulado_$(date -d yesterday +%Y%m%d).sql; then
		exit 0
	else
		ls $DIR/Cedulado_CNE_$(date -d yesterday +%Y%m%d)*.send | while read i
		do
			echo $i
			atool -X $DIR $i
		done
		#rm -r Unpack-*
		find $DIR -name '*.xml'  -print | while read j
		do
			cat $j | tr '\011' ' ' | tr -c -d 0-9a-zA-ZáéíóúàèìòùñÑçÇäëïöüÁÉÍÓÚÀÈÌÒÙÄËÏÖÜ' ''\012''015'\'-
			xmllint --noout $j --schema $DIR/Cedulado.xsd
			value=$?
			if [ $value -ne 0 ]; then
				mv $j "NO_"$j
				echo "Error valor "$value" en el archivo "$j >> /var/log/libwriteall.log
			else
				xml2 < $j > $j.txt
				2csv datos letra cedula PaisOrigen Nacionalidad PNombre SNombre PApellido SApellido FechaNac FechaCedOrg CodObjecion CodOficina CodEstadoCivil Naturalizado Sexo < $j.txt > $j.csv
				rm $j
				rm $j\.txt
			fi
		done
		find $DIR -name '*.csv'  -print | while read k
		do
			cat $k >> $DIR/Cedulado.csv
		done

		cat $DIR/Cedulado.csv | sed -e "s/^/'/g; s/,/','/g; s/$/'/g" >> $DIR/Cedulado_tmp.csv
		cat $DIR/Cedulado_tmp.csv | sed -e 's/^/insert into saime.saime_personas (letra,numcedula,paisorigen,nacionalidad,primernombre,segundonombre,primerapellido,segundoapellido,fechanac,fechacedorg,codobjecion,codoficina,estado_civil,naturalizado,sexo) values (/g; s/$/);/g' >> $DIR/Cedulado_insert.sql
		cat $DIR/Cedulado_insert.sql | sed -f $DIR/regexp_insert > $DIR/Cedulado_$(date -d yesterday +%Y%m%d).sql

		rm $DIR/Cedulado.csv 
		rm $DIR/Cedulado_tmp.csv
		rm $DIR/Cedulado_insert.sql

		result=$(ls -l /home/rialfi/saime/Cedulado_$(date -d yesterday +%Y%m%d).sql | wc -l)

		if [ $result -eq 0 ]; then
			echo "El archivo de actualizacion esta vacio de la fecha "$(date -d yesterday +%d-%m-%Y) | mail -s "Actualizaciones diarias Cedulado" cramirez@rialfi.com
			echo "El archivo de actualizacion esta vacio de la fecha "$(date -d yesterday +%d-%m-%Y) >> /var/log/libwriteall.log
		else
			lineas=$(cat $DIR/Cedulado_$(date -d yesterday +%Y%m%d).sql | wc -l)
			echo "El archivo de actualizacion para el dia "$(date -d yesterday +%d-%m-%Y)" contiene "$lineas" de actualizaciones de cedulas" | mail -s "Actualizaciones diarias Cedulado" cramirez@rialfi.com
			echo "El archivo de actualizacion para el dia "$(date -d yesterday +%d-%m-%Y)" contiene "$lineas" de actualizaciones de cedulas" >> /var/log/libwriteall.info
			rm -r $DIR/Cedulado_CNE_$(date -d yesterday +%Y%m%d)*
		fi
		if test -e $DIR/Cedulado_$(date -d "7 days ago" +%Y%m%d).sql; then
            rm $DIR/Cedulado_$(date -d "7 days ago" +%Y%m%d).sql
        fi
	fi
else
	exit 0
fi