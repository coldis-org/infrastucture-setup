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
			printf 'WARN: Unknown option (ignored): %s\n' "${1}" >&2
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
${DEBUG} && echo  "Running 'aws_iam_create_admin_group_users'"
${DEBUG} && ${AWS_CONFIG_FILE} && echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"

aws iam update-account-password-policy \
		--minimum-password-length ${AWS_IAM_PASSWORD_POLICY_MINIMUM_SIZE} \
		--${AWS_IAM_PASSWORD_POLICY_SYMBOLS}require-symbols \
		--${AWS_IAM_PASSWORD_POLICY_NUMBERS}require-numbers \
		--${AWS_IAM_PASSWORD_POLICY_UPPERCASE}require-uppercase-character \
		--${AWS_IAM_PASSWORD_POLICY_LOWERCASE}require-lowercase-characters \
		--${AWS_IAM_PASSWORD_POLICY_ALLOW_CHANGE}allow-users-to-change-password

# Creates AWS IAM system admin group and users.
aws_iam_create_group_users \
		--aws-iam-group-path ${AWS_IAM_SYSTEM_ADMIN_GROUP_PATH} \
		--aws-iam-group-name ${AWS_IAM_SYSTEM_ADMIN_GROUP_NAME} \
		--aws-iam-group-policies ${AWS_IAM_SYSTEM_ADMIN_POLICIES} \
		--aws-iam-group-users-path ${AWS_IAM_SYSTEM_ADMIN_USERS_PATH} \
		--aws-iam-group-users-names ${AWS_IAM_SYSTEM_ADMIN_USERS_NAMES} \
		--aws-iam-group-users-password ${AWS_IAM_SYSTEM_ADMIN_USERS_PASSWORD} \
		--aws-config-file ${AWS_CONFIG_FILE} \
		${DEBUG_OPT}

# Creates AWS IAM billing group and users.
aws_iam_create_group_users \
		--aws-iam-group-path ${AWS_IAM_BILLING_GROUP_PATH} \
		--aws-iam-group-name ${AWS_IAM_BILLING_GROUP_NAME} \
		--aws-iam-group-policies ${AWS_IAM_BILLING_POLICIES} \
		--aws-iam-group-users-path ${AWS_IAM_BILLING_USERS_PATH} \
		--aws-iam-group-users-names ${AWS_IAM_BILLING_USERS_NAMES} \
		--aws-iam-group-users-password ${AWS_IAM_BILLING_USERS_PASSWORD} \
		--aws-config-file ${AWS_CONFIG_FILE} \
		${DEBUG_OPT}

# Print script end if on debug mode.
${DEBUG} && echo  "Finishing 'aws_iam_create_admin_group_users'"





