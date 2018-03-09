#!/usr/bin/env bash

set -e
cd "${1}"
exec 3>&1
exec 1>&2

payload=$(mktemp /tmp/resource-in.XXXXXX)

cat > "${payload}" <&0

aws_access_key_id="$(jq -r '.source.aws_access_key_id// ""' < "${payload}")"
aws_secret_access_key="$(jq -r '.source.aws_secret_access_key// ""' < "${payload}")"
export AWS_ACCESS_KEY_ID=${aws_access_key_id}
export AWS_SECRET_ACCESS_ID=${aws_secret_access_key}
# Sensitive data should not be printed after set +x
set +x

job_dir="$(jq -r '.params.job_dir// ""' < "${payload}")"
action="$(jq -r '.params.action// ""' < "${payload}")"
handler="$(jq -r '.params.handler// ""' < "${payload}")"

serverless_version="$(jq -n "{serverless_version:{serverless_version:\"$(serverless --version)\"}}")"
timestamp="$(jq -n "{version:{timestamp:\"$(date +%s)\"}}")"


case ${action} in
	deploy)
		echo "Serverless Deploy"
		cd $(ls)/${job_dir} && serverless ${action}

		exit 0
	  ;;

	remove)
		echo "Removing Serverless"
		cd $(ls)/${job_dir} && serverless ${action}
		exit 0
	  ;;

	*)
		echo "ERROR:"
		exit 1
	  ;;
esac


echo "$timestamp" $serverless_version| jq -s add  >&3
