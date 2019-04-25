#!/bin/sh

# Default script behavior.
set -o errexit
#set -o pipefail

# Debug is disabled by default.
DEBUG=false
DEBUG_OPT=

# Default paramentes.
SERVICE_CONFIG_FILE=/project/service.json

# For each argument.
while :; do
	case ${1} in
		
		# If debug should be enabled.
		--debug)
			DEBUG=true
			DEBUG_OPT="--debug"
			;;

		# Service configuration file.
		-f|--service-config-file)
			SERVICE_CONFIG_FILE=/project/${2}
			shift
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

# Print arguments if on debug mode.
${DEBUG} && echo "Running 'dcos_deploy_marathon'"
${DEBUG} && echo "SERVICE_CONFIG_FILE=${SERVICE_CONFIG_FILE}"

# Generates the deploy id.
DEPLOY_ID="`head /dev/urandom | tr -dc \"0-9\" | head -c 13`"
${DEBUG} && echo "DEPLOY_ID=${DEPLOY_ID}"
echo `jq ".env.DEPLOY_ID = \"${DEPLOY_ID}\"" ${SERVICE_CONFIG_FILE}` > ${SERVICE_CONFIG_FILE}

# If the application exists in the cluster.
if dcos marathon app show `jq -r ".id" < ${SERVICE_CONFIG_FILE}`
then
	# Updates the app in the cluster.
	${DEBUG} && echo "Updating app in the cluster"
	SERVICE_ID="`jq -r ".id" < ${SERVICE_CONFIG_FILE}`"
	DEPLOYMENT_ID="`dcos marathon app update ${SERVICE_ID} < ${SERVICE_CONFIG_FILE}`"
	DEPLOYMENT_ID=${DEPLOYMENT_ID#Created deployment *}
	${DEBUG} && echo "Watching deployment ${DEPLOYMENT_ID}"
	dcos marathon deployment watch --max-count=12 --interval=15 ${DEPLOYMENT_ID}
# If the application does not exist in the cluster.
else
	# Adds the app to the cluster.
	${DEBUG} && echo "Adding app to the cluster"
	DEPLOYMENT_ID="`dcos marathon app add < ${SERVICE_CONFIG_FILE}`"
	DEPLOYMENT_ID=${DEPLOYMENT_ID#Created deployment *}
	${DEBUG} && echo "Watching deployment ${DEPLOYMENT_ID}"
	dcos marathon deployment watch --max-count=12 --interval=15 ${DEPLOYMENT_ID}
fi


