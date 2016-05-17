#!/bin/bash -

# bob is Backup On Bucket ...

CONFIG_FILE=.bobconfig

if [ ! -e ./$CONFIG_FILE ] ; then
	echo "Unable to load config" ;
	exit 2
else  
	source ~/bob-config
fi

SCRIPT_NAME=$(basename $0)

LOG_FILE=$(mktemp --suffix=${SCRIPT_NAME/.sh/})

usage() {
	echo -e "bucket AND\n\tcreate \"bucket name\"\n\tlist \"bucket name\" OR "all"\n\tdelete \"bucket name\"\nbackup AND\n\tstart OR stop"
}

cleanning() {
	rm -f $LOG_FILE
}

trap cleanning EXIT

error_with_exit() {
	cat $LOG_FILE
	exit 2
}

verify_args() {
	echo "$# args are $1 ou $* ou $@"
	NB_ARGS="$#"
	NB_ARGS_EXPECT=${@: -1}
	if (( $NB_ARGS < $NB_ARGS_EXPECT )) ; then
		echo "problem"
		exit 2
	fi 
}

create_bucket() {
	BUCKET_NAME=$3
	if ! gsutil mb -c $TYPE -l $LOCALISATION -p $PROJECT_ID gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	else
		if ! gsutil ls -Lb gs://pouetpouet | grep -E "Storage|Versioning|Lifecycle" ; then
			error_with_exit
		fi
	fi
}

activate_versioning() {
	BUCKET_NAME=$3
	if ! gsutil versioning set on gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	fi
}

activate_lifecycle() {
	BUCKET_NAME=$3
	LIFECYCLE_CONFIG_FILE=${$4:-lifecycle_config.json}
	if [ ! -e $2 ] ; then 
		false
	else
		if ! gsutil lifecycle set $LIFECYCLE_CONFIG_FILE gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
			false
		fi
	fi
}	

if_bucket_exist() {
	BUCKET_NAME=$3
	if ! gsutil ls -b gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	fi
}	
		
delete_bucket() {
	BUCKET_NAME=$3
	if ! if_bucket_exist ${BUCKET_NAME} 2>> $LOG_FILE ; then
		error_with_exit
	else
		BUCKET_NAME=$3
		if ! gsutil rb gs://${BUCKET_NAME} 2>> $LOG_FILE ; then
			error_with_exit
		else
			echo ""
		fi
	fi
}

backup_on_bucket() {
	if_bucket_exist
	
}
case "$1" in 
	bucket)
		case "$2" in 
			create)
				verify_args "$@" 4
				create_bucket "$@"	
			;;
			list)
				verify_args "$@" 3
				if_bucket_exist "$@"
			;;
			delete)
				verify_args "$@" 4
				delete_bucket "$@"
			;;
			*)
				usage
			;;
		esac
	;;
	backup)
		case "$2" in 
			sync)
				verify_args "$@" 4
				create_bucket "$@"	
			;;
			cp)
				verify_args "$@" 4
				create_bucket "$@"	
			;;
			*|-h|--help)
				verify_args "$@" 4
				create_bucket "$@"	
			;;
		esac
	;;
	*)
		usage
	;;
esac
