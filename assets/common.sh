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

aws_access_key_id="$(jq -r '.source.aws_access_key_id// ""' < "${payload}")"
aws_secret_access_key="$(jq -r '.source.aws_secret_access_key// ""' < "${payload}")"


exitOutput(){
	serverless_version="$(jq -n "{serverless_version:{serverless_version:\"$(serverless --version)\"}}")"
	timestamp="$(jq -n "{version:{timestamp:\"$(date +%s)\"}}")"
	echo "$timestamp" $serverless_version| jq -s add  >&3
	exit $1
}

if [  -z "$aws_access_key_id" ];then
	export AWS_ACCESS_KEY_ID=${aws_access_key_id}
else
	exitOutput 1
fi

if [  -z "$aws_secret_access_key" ];then
	export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
else
	exitOutput 1
fi


