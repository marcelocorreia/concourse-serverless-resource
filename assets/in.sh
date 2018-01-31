#!/usr/bin/env bash

source $(dirname $0)/common.sh

case ${action} in
	info)
		echo "Serverless Info"
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput 0
	  ;;
	metrics)
		echo "Serverless Metrics"
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput 0
	  ;;
	invoke)
		echo "Invoking Lambda function: ${handler}"
		if [ ${handler} == "" ];then
			echo "ERROR: handler undefined"
			exitOutput && exit 1
		fi
		cd $(ls)/${job_dir} && serverless invoke -f ${handler} -l
		exitOutput
	  ;;

	*)
		echo "ERROR:"
		exitOutput 1
	  ;;
esac

