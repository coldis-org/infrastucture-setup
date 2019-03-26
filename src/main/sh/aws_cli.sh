#!/bin/bash

# Default script behavior.
set -o errexit
set -o nounset
set -o pipefail

# Debug is disabled by default.
DEBUG=false
DEBUG_OPT=

# No config file by default.
AWS_CONFIG_FILE=false

# For each argument.
POSITIONAL=()
while [[ $# -gt 0 ]]
do
	ARG_KEY="${1}"
	case ${ARG_KEY} in

		# Debug argument.
		--debug)
		DEBUG=true
		DEBUG_OPT="--debug"
		shift
		;;

		# AWS Access Key Id.
		-k|--aws-key)
		readonly AWS_ACCESS_KEY_ID="${2}"
		shift
		shift
		;;

		# AWS Secret Key.
		-s|--aws-secret)
		readonly AWS_SECRET_ACCESS_KEY="${2}"
		shift
		shift
		;;

		# AWS region argument.
		-r|--aws-default-region)
		readonly AWS_DEFAULT_REGION="${2}"
		shift
		shift
		;;

		# Work folder.
		-w|--aws-work-folder)
		readonly AWS_WORK_FOLDER="${2}"
		shift
		shift
		;;
		
		# AWS config file argument.
		-f|--aws-config-file)
		AWS_CONFIG_FILE="${2}"
		shift
		shift
		;;

		# Unkown option.
		*)
		# Saves it in an array for later.
		POSITIONAL+=("${1}") 
		shift
		;;

	esac
done
# Restore positional parameters.
set -- "${POSITIONAL[@]}" 

# Enables interruption signal handling.
trap - INT TERM

# Puts the AWS config information in the the conext variables.
if [ -f ${AWS_CONFIG_FILE} ]
then 
	. ${AWS_CONFIG_FILE}
	${DEBUG} && cat ${AWS_CONFIG_FILE}
fi

# Print arguments if on debug mode.
${DEBUG} && echo  "Running 'aws_cli.sh'"
${DEBUG} && ${AWS_CONFIG_FILE} && echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"
${DEBUG} && echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
${DEBUG} && echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
${DEBUG} && echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
${DEBUG} && echo "AWS_WORK_FOLDER=${AWS_WORK_FOLDER}"

# Executes the AWS CLI command.
${DEBUG} && echo "Executing AWS CLI command '${@: -1}'"
docker run --rm \
	-t $(tty &>/dev/null && echo "-i") \
	-e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
	-e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
	-e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
	-v "${AWS_WORK_FOLDER}:/project" \
	mesosphere/aws-cli ${@: -1}


