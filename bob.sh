#!/bin/bash -

# bob is Backup On Bucket ...

source ~/bob-config


usage() {
}

create_bucket() {
	BUCKET_NAME=$1
	gsutil mb -c $TYPE -l $LOCALISATION -p $PROJECT_ID gs://${BUCKET_NAME}
}

activate_versioning() {
	BUCKET_NAME=$1
	gsutil versioning set on gs://${BUCKET_NAME}
}

activate_lifecycle() {
	BUCKET_NAME=$1
	LIFECYCLE_CONFIG_FILE=${$2:-lifecycle_config.json}
	if [ ! -e $2 ] ; then 
		echo ""
	else
		gsutil lifecycle set $LIFECYCLE_CONFIG_FILE gs://${BUCKET_NAME}
	fi
}	
check_bucket() {
	BUCKET_NAME=$1
	if ! gsutil ls -b gs://${BUCKET_NAME} ; then
		echo ""
	fi
		
		
deletebucket() {
	if ! check_bucket gs://${BUCKET_NAME} ; then
		echo ""
	else
		if ! gsutil rb gs://${BUCKET_NAME} ; then
			echo ""
		else
			echo ""
		fi
	fi

}



