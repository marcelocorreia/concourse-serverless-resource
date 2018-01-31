#!/usr/bin/env bash

set -e
cd "${1}"
exec 3>&1
exec 1>&2
set +x

payload=$(mktemp /tmp/resource-in.XXXXXX)

cat > "${payload}" <&0

sss=$(jq -r '.source// ""' < "${payload}")
echo "-> ${sss} <-"

job_dir="$(jq -r '.params.job_dir// ""' < "${payload}")"
action="$(jq -r '.params.action// ""' < "${payload}")"
handler="$(jq -r '.params.handler// ""' < "${payload}")"

aws_access_key_id="$(jq -r '.source.aws_access_key_id// ""' < "${payload}")"
aws_secret_access_key="$(jq -r '.source.aws_secret_access_key// ""' < "${payload}")"

serverless_version="$(jq -n "{serverless_version:{serverless_version:\"$(serverless --version)\"}}")"
timestamp="$(jq -n "{version:{timestamp:\"$(date +%s)\"}}")"


case ${action} in
	deploy)
		echo "Serverless Deploy"
		cd $(ls)/${job_dir} && serverless ${action}
	  ;;

	remove)
		echo "Removing Serverless"
		cd $(ls)/${job_dir} && serverless ${action}
	  ;;

	*)
		echo "ERROR:"
	  ;;
esac


echo "$timestamp" $serverless_version| jq -s add  >&3
