#!/bin/bash -xl

FILE_DONE=/data/moloch/etc/bootstrap.done


if [ -z "${ESHOST}" ]
then
    ESHOST="localhost"
fi

if [ -z "${MOLOCH_LOCALELASTICSEARCH}" ]
then
    MOLOCH_LOCALELASTICSEARCH='yes'
fi

if [ -z "${MOLOCH_PASSWORD}" ]
then
    MOLOCH_PASSWORD="password"
fi

echo "Start moloch bootstrap for demo docker"
if [ -f "${FILE_DONE}" ]
then
	echo "Bootstrap already done! Remove ${FILE_DONE} if you want to re-do it."
	exit 0
fi

if [ "${MOLOCH_LOCALELASTICSEARCH}" = "yes" -a "${ESHOST}" = "localhost" ]
then
	# Waiting a minute for elastic search to become ready
    echo "Waiting for elastic search"
	let TRIES=0
	let WAIT_SECS=120
	while [ ${TRIES} -lt ${WAIT_SECS} ]
	do
		curl -I "${ESHOST}:9200" 2> /dev/null
		if [ $? -eq 0 ]
		then
			break;
		fi
		TRIES=$(( $TRIES+1 ))
		echo  "Waiting for ES : ... ${TRIES}"
		sleep 1
	done
    echo "Seen elastic search at ${TRIES}"

	if [ ${TRIES} -ge ${WAIT_SECS} ]
	then
		echo "Bootstrap failed. Couldn't not ping elasticsearch service."
		exit 0
	fi
fi

echo "Inititalize elastic search database"
/data/moloch/db/db.pl http://${ESHOST}:9200 init <<EOF
INIT
EOF

echo "Add admin user"
/data/moloch/bin/moloch_add_user.sh admin "Admin User" ${MOLOCH_PASSWORD} --admin


echo "Enable moloch services"
systemctl enable molochcapture
systemctl enable molochviewer

echo "Start moloch services"
systemctl start molochviewer
systemctl start molochcapture

echo "Bootstrap done"
touch /data/moloch/etc/bootstrap.done
