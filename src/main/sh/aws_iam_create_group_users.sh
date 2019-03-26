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
		
		# Group path.
		--aws-iam-group-path)
		readonly AWS_IAM_GROUP_PATH="${2}"
		shift
		shift
		;;
		
		# Group name.
		--aws-iam-group-name)
		readonly AWS_IAM_GROUP_NAME="${2}"
		shift
		shift
		;;
		
		# Group policies.
		--aws-iam-group-policies)
		readonly AWS_IAM_GROUP_POLICIES="${2}"
		shift
		shift
		;;
		
		# Group users path.
		--aws-iam-group-users-path)
		readonly AWS_IAM_GROUP_USERS_PATH="${2}"
		shift
		shift
		;;
		
		# Group users names.
		--aws-iam-group-users-names)
		readonly AWS_IAM_GROUP_USERS_NAMES="${2}"
		shift
		shift
		;;
		
		# Group users password.
		--aws-iam-group-users-password)
		readonly AWS_IAM_GROUP_USERS_PASSWORD="${2}"
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
${DEBUG} && echo  "Running 'aws_iam_create_group_users.sh'"
${DEBUG} && ${AWS_CONFIG_FILE} && echo "AWS_CONFIG_FILE=${AWS_CONFIG_FILE}"
${DEBUG} && echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
${DEBUG} && echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
${DEBUG} && echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
${DEBUG} && echo "AWS_WORK_FOLDER=${AWS_WORK_FOLDER}"
${DEBUG} && echo "AWS_IAM_GROUP_PATH=${AWS_IAM_GROUP_PATH}"
${DEBUG} && echo "AWS_IAM_GROUP_NAME=${AWS_IAM_GROUP_NAME}"
${DEBUG} && echo "AWS_IAM_GROUP_POLICIES=${AWS_IAM_GROUP_POLICIES}"
${DEBUG} && echo "AWS_IAM_GROUP_USERS_PATH=${AWS_IAM_GROUP_USERS_PATH}"
${DEBUG} && echo "AWS_IAM_GROUP_USERS_NAMES=${AWS_IAM_GROUP_USERS_NAMES}"
${DEBUG} && echo "AWS_IAM_GROUP_USERS_PASSWORD=${AWS_IAM_GROUP_USERS_PASSWORD}"

# If there is no AWS IAM group for the name.
if ${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
		--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
		--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} \
		"iam get-group --group-name ${AWS_IAM_GROUP_NAME}" || false
then
	${DEBUG} && echo "AWS IAM group '${AWS_IAM_GROUP_NAME}' already exists"
else 
	# Creates AWS IAM group.
	${DEBUG} && echo "Creating AWS IAM group '${AWS_IAM_GROUP_NAME}'"
	${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
			--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
			--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} "iam  create-group \
			--path ${AWS_IAM_GROUP_PATH} --group-name ${AWS_IAM_GROUP_NAME}"
fi

# For each group policy.
IFS=','; for AWS_IAM_GROUP_POLICY in `echo "${AWS_IAM_GROUP_POLICIES}"`
do
	if [ "${AWS_IAM_GROUP_POLICY}" != "" ]
		then
		# Sets the group policy.
		${DEBUG} && echo "Setting AWS IAM group policy '${AWS_IAM_GROUP_POLICY}'"
		${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
				--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
				--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} "iam  attach-group-policy \
				--policy-arn ${AWS_IAM_GROUP_POLICY} \
				--group-name ${AWS_IAM_GROUP_NAME}"
	fi
done

# For each group user.
IFS=','; for AWS_IAM_USER_NAME in `echo "${AWS_IAM_GROUP_USERS_NAMES}"`
do
	if [ "${AWS_IAM_USER_NAME}" != "" ] 
	then
		# If there is no AWS IAM user for the name.
		if ${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
				--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
				--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} \
				"iam get-user --user-name ${AWS_IAM_USER_NAME}" || false
		then
			${DEBUG} && echo "AWS IAM user '${AWS_IAM_USER_NAME}' already exists"
		else 
			${DEBUG} && echo "Creating user '${AWS_IAM_USER_NAME}'"
			${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
					--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
					--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} "iam create-user \
					--path ${AWS_IAM_GROUP_USERS_PATH} \
					--user-name ${AWS_IAM_USER_NAME}"
			${DEBUG} && echo "Creating user profile '${AWS_IAM_USER_NAME}'"
			${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
					--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
					--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} "iam create-login-profile \
					--user-name ${AWS_IAM_USER_NAME} \
					--password ${AWS_IAM_GROUP_USERS_PASSWORD} \
					--password-reset-required"
		fi
		# Adds the user to the group.
		${DEBUG} && echo "Adding user '${AWS_IAM_USER_NAME}' to group '${AWS_IAM_GROUP_NAME}'"
		${BASH_SOURCE%/*}/aws_cli.sh --aws-key ${AWS_ACCESS_KEY_ID} \
				--aws-secret ${AWS_SECRET_ACCESS_KEY} --aws-default-region ${AWS_DEFAULT_REGION} \
				--aws-work-folder ${AWS_WORK_FOLDER} ${DEBUG_OPT} "iam \
				add-user-to-group --group-name ${AWS_IAM_GROUP_NAME} \
				--user-name ${AWS_IAM_USER_NAME}"
	fi
done

