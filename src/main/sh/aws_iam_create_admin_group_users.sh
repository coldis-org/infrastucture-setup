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
${DEBUG} && echo  "Running 'aws_iam_create_admin_group_users.sh'"
${DEBUG} && ${AWS_CONFIG_FILE} && echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"
${DEBUG} && echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
${DEBUG} && echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
${DEBUG} && echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
${DEBUG} && echo "AWS_WORK_FOLDER=${AWS_WORK_FOLDER}"

${BASH_SOURCE%/*}/aws_cli.sh \
		--aws-iam-group-path ${AWS_IAM_SYSTEM_ADMIN_GROUP_PATH}\
		--aws-iam-group-name ${AWS_IAM_SYSTEM_ADMIN_GROUP_NAME}\
		--aws-iam-group-policies ${AWS_IAM_SYSTEM_ADMIN_POLICIES} \
		--aws-iam-group-users-path ${AWS_IAM_SYSTEM_ADMIN_USERS_PATH} \
		--aws-iam-group-users-names ${AWS_IAM_SYSTEM_ADMIN_USERS_NAMES} \
		--aws-iam-group-users-password ${AWS_IAM_SYSTEM_ADMIN_USERS_PASSWORD} \
		--aws-config-file ${AWS_CONFIG_FILE} \
		"iam update-account-password-policy \
		--minimum-password-length ${AWS_IAM_PASSWORD_POLICY_MINIMUM_SIZE} \
		--${AWS_IAM_PASSWORD_POLICY_SYMBOLS}require-symbols
		--${AWS_IAM_PASSWORD_POLICY_NUMBERS}require-numbers
		--${AWS_IAM_PASSWORD_POLICY_UPPERCASE}require-uppercase-character
		--${AWS_IAM_PASSWORD_POLICY_LOWERCASE}require-lowercase-characters
		--${AWS_IAM_PASSWORD_POLICY_ALLOW_CHANGE}allow-users-to-change-password"

# Creates AWS IAM system admin group and users.
${BASH_SOURCE%/*}/aws_iam_create_group_users.sh \
		--aws-iam-group-path ${AWS_IAM_SYSTEM_ADMIN_GROUP_PATH}\
		--aws-iam-group-name ${AWS_IAM_SYSTEM_ADMIN_GROUP_NAME}\
		--aws-iam-group-policies ${AWS_IAM_SYSTEM_ADMIN_POLICIES} \
		--aws-iam-group-users-path ${AWS_IAM_SYSTEM_ADMIN_USERS_PATH} \
		--aws-iam-group-users-names ${AWS_IAM_SYSTEM_ADMIN_USERS_NAMES} \
		--aws-iam-group-users-password ${AWS_IAM_SYSTEM_ADMIN_USERS_PASSWORD} \
		--aws-config-file ${AWS_CONFIG_FILE} \
		${DEBUG_OPT}

# Creates AWS IAM billing group and users.
${BASH_SOURCE%/*}/aws_iam_create_group_users.sh \
		--aws-iam-group-path ${AWS_IAM_BILLING_GROUP_PATH}\
		--aws-iam-group-name ${AWS_IAM_BILLING_GROUP_NAME}\
		--aws-iam-group-policies ${AWS_IAM_BILLING_POLICIES} \
		--aws-iam-group-users-path ${AWS_IAM_BILLING_USERS_PATH} \
		--aws-iam-group-users-names ${AWS_IAM_BILLING_USERS_NAMES} \
		--aws-iam-group-users-password ${AWS_IAM_BILLING_USERS_PASSWORD} \
		--aws-config-file ${AWS_CONFIG_FILE} \
		${DEBUG_OPT}






