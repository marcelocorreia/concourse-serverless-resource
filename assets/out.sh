#!/usr/bin/env bash

set -e
cd "${1}"
exec 3>&1
exec 1>&2
set +x

payload=$(mktemp /tmp/resource-in.XXXXXX)
cat > "${payload}" <&0

job_dir="$(jq -r '.params.job_dir// ""' < "${payload}")"
action="$(jq -r '.params.action// ""' < "${payload}")"
handler="$(jq -r '.params.handler// ""' < "${payload}")"
aws_access_key_id="$(jq -r '.params.aws_access_key_id// ""' < "${payload}")"
aws_secret_access_key="$(jq -r '.params.aws_secret_access_key// ""' < "${payload}")"

if [  aws_access_key_id != "" ];then
	export AWS_ACCESS_KEY_ID=${aws_access_key_id}
fi

if [  aws_secret_access_key != "" ];then
	export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
fi

exitOutput(){
	serverless_version="$(jq -n "{serverless_version:{serverless_version:\"$(serverless --version)\"}}")"
	timestamp="$(jq -n "{version:{timestamp:\"$(date +%s)\"}}")"
	echo "$timestamp" $serverless_version| jq -s add  >&3
}

case ${action} in
	deploy)
		echo Deploying Serverless
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput && exit 0
	  ;;
	logs)
		echo Removing Serverless
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput && exit 0
	  ;;
	info)
		echo Removing Serverless
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput && exit 0
	  ;;
	metrics)
		echo Removing Serverless
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput && exit 0
	  ;;
	remove)
		echo Removing Serverless
		cd $(ls)/${job_dir} && serverless ${action}
		exitOutput && exit 0
	  ;;
	invoke)
		echo "TODO://"
		if [ ${handler} == "" ];then
			echo "ERROR: handler undefined"
			exitOutput && exit 1
		fi
		cd $(ls)/${job_dir} && serverless invoke -f ${handler} -l
		exitOutput && exit 0
	  ;;

	*)
		echo "ERROR:"
		exitOutput && exit 1
	  ;;
esac

