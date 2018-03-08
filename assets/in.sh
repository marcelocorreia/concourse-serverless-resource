#!/usr/bin/env bash

source $(dirname $0)/common.sh

case ${action} in
	info)
		echo "Serverless Info"
		cd $(ls)/${job_dir} && serverless ${action}
		exit 0
	  ;;
	metrics)
		echo "Serverless Metrics"
		cd $(ls)/${job_dir} && serverless ${action}
		exit 0
	  ;;
	invoke)
		echo "Invoking Lambda function: ${handler}"
		if [ ${handler} == "" ];then
			echo "ERROR: handler undefined"
			exitOutput && exit 1
		fi
		cd $(ls)/${job_dir} && serverless invoke -f ${handler} -l
		exit 0
	  ;;

	*)
		echo "ERROR:"
		exit 1
	  ;;
esac

