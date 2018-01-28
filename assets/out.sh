#!/usr/bin/env bash

source $(dirname $0)/common.sh

case ${action} in
	deploy)
		echo "Serverless Deploy"
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput 0
	  ;;

	remove)
		echo "Removing Serverless"
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput 0
	  ;;

	*)
		echo "ERROR:" >&2
		exitOutput 1
	  ;;
esac

