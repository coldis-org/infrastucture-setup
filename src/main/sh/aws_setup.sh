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

# Puts the AWS config information in the the conext variables.
if [ -f ${AWS_CONFIG_FILE} ]
then 
	. ${AWS_CONFIG_FILE}
	${DEBUG} && cat ${AWS_CONFIG_FILE}
fi

# Print arguments if on debug mode.
${DEBUG} && echo  "Running 'aws_setup.sh'"
${DEBUG} && ${AWS_CONFIG_FILE} && echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"

# Enables interruption signal handling.
trap - INT TERM

# Puts the AWS config information in the the conext variables.
. ${AWS_CONFIG_FILE}
${DEBUG} && cat ${AWS_CONFIG_FILE}

# Creates AWS IAM groups and users.
${BASH_SOURCE%/*}/aws_iam_create_admin_group_users.sh --aws-config-file ${AWS_CONFIG_FILE} \
		${DEBUG_OPT}


