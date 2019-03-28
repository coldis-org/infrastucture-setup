#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Debug is disabled by default.
DEBUG=false
DEBUG_OPT=

# No config file by default.
AWS_CONFIG_FILE=false

# For each argument.
while :; do
	case ${1} in
		
		# Debug argument.
		--debug)
			DEBUG=true
			DEBUG_OPT="--debug"
			;;

		# AWS config file argument.
		-f|--aws-config-file)
			AWS_CONFIG_FILE="${2}"
			shift
			;;

		# Unkown option.
		-?*)
			printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
			;;

		# No more options.
		*)
			break

	esac 
	shift
done

# Using unavaialble variables should fail the script.
set -o nounset

# Enables interruption signal handling.
trap - INT TERM

# Puts the AWS config information in the the conext variables.
if [ -f ${AWS_CONFIG_FILE} ]
then 
	. ${AWS_CONFIG_FILE}
	${DEBUG} && cat ${AWS_CONFIG_FILE}
fi

# Print arguments if on debug mode.
${DEBUG} && echo  "Running 'aws_setup'"
${DEBUG} && ${AWS_CONFIG_FILE} && echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"

# Puts the AWS config information in the the conext variables.
. ${AWS_CONFIG_FILE}
${DEBUG} && cat ${AWS_CONFIG_FILE}

# Creates AWS IAM groups and users.
aws_iam_create_admin_group_users --aws-config-file ${AWS_CONFIG_FILE} \
		${DEBUG_OPT}
		
# Print script end if on debug mode.
${DEBUG} && echo  "Finishing 'aws_setup'"



