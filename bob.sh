#!/bin/bash -

# bob is Backup On Bucket ...

CONFIG_FILE=bob-config

if [ ! -e ~/$CONFIG_FILE ] ; then
	echo "Unable to load config" ;
	exit 2
else  
	source ~/bob-config
fi

SCRIPT_NAME=$(basename $0)

LOG_FILE=$(mktemp --suffix=${SCRIPT_NAME/.sh/})

usage() {
	echo "help !!!"
}

function cleanning {
	rm -f $LOG_FILE
}

trap cleanning EXIT

function error_with_exit {
	cat $LOG_FILE
	exit 2
}

function verify_args {
	echo "$# args are $1 ou $@"
	#NB_ARGS="$#"
	#if (( $NB_ARGS <= 0 )) ; then
	#	exit 2
	#fi 
}

function create_bucket {
	BUCKET_NAME=$1
	if ! gsutil mb -c $TYPE -l $LOCALISATION -p $PROJECT_ID gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	fi
}

function activate_versioning {
	BUCKET_NAME=$1
	if ! gsutil versioning set on gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	fi
}

function activate_lifecycle {
	BUCKET_NAME=$1
	LIFECYCLE_CONFIG_FILE=${$2:-lifecycle_config.json}
	if [ ! -e $2 ] ; then 
		false
	else
		if ! gsutil lifecycle set $LIFECYCLE_CONFIG_FILE gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
			false
		fi
	fi
}	

function if_bucket_exist {
	BUCKET_NAME=$2
	if ! gsutil ls -b gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	fi
}	
		
function delete_bucket {
	if ! if_bucket_exist ${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	else
		if ! gsutil rb gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
			error_with_exit
		else
			true
		fi
	fi
}

case "$1" in 

	bucket)

		case "$1" in 

			create)
				verify_args "$#"
				create_bucket $2	
			;;

			list)
				verify_args "$#"
				if_bucket_exist $2
			;;

			delete)
				verify_args "$#"
				delete_bucket $2
			;;

			*)
				usage
			;;
		esac
	;;

	backup)
	;;

	*)
		usage
	;;
esac
