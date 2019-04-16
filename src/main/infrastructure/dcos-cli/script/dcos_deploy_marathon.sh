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
${DEBUG} && echo  "Running 'dcos_deploy_marathon'"
${DEBUG} && echo  "SERVICE_CONFIG_FILE=${SERVICE_CONFIG_FILE}"

# If the application exists in the cluster.
if dcos marathon app show `jq -r ".id" < ${SERVICE_CONFIG_FILE}`
then
	# Updates the app in the cluster.
	${DEBUG} && echo  "Updating app in the cluster"
	dcos marathon app update < /project/${SERVICE_CONFIG_FILE}
# If the application does not exist in the cluster.
else
	# Adds the app to the cluster.
	${DEBUG} && echo  "Adding app to the cluster"
	dcos marathon app add < /project/${SERVICE_CONFIG_FILE}
fi


