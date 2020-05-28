# check_env_vars checks environment variables
# if variables to create non-admin user are provided, sets CREATE_USER=1
# if MEMBER_ID variable is set, checks also replication variables
function check_env_vars() {
  local readonly database_regex='^[^/\. "$]*$'

  [[ -v MONGODB_ADMIN_PASSWORD ]] || usage "MONGODB_ADMIN_PASSWORD has to be set."

  if [[ -v MONGODB_USER || -v MONGODB_PASSWORD || -v MONGODB_DATABASE  ]]; then
    [[ -v MONGODB_USER && -v MONGODB_PASSWORD && -v MONGODB_DATABASE  ]] || usage "You have to set all or none of variables: MONGODB_USER, MONGODB_PASSWORD, MONGODB_DATABASE"

    [[ "${MONGODB_DATABASE}" =~ $database_regex ]] || usage "Database name must match regex: $database_regex"
    [ ${#MONGODB_DATABASE} -le 63 ] || usage "Database name too long (maximum 63 characters)"

    export CREATE_USER=1
  fi

  if [[ ! -v MONGODB_DEPLOYMENT ]]; then
	 info "MONGODB_DEPLOYMENT not set, assuming Standalone"
	 export MONGODB_DEPLOYMENT=standalone
  fi
  if [ "${MONGODB_DEPLOYMENT}" = "replicaset" ] && [ ! -v MONGODB_REPLICA_NAME ]; then
	  usage "MONGODB_REPLICA_NAME not defined"
  fi
  if [ -v MONGODB_INITIATE_REPLICA ] && [ "${MONGODB_DEPLOYMENT}" = "standalone" ]; then
	  usage "MONGODB_INITIATE_REPLICA cannot be used with standalone"
  fi
  if [[ -v MEMBER_ID ]]; then
    [[ -v MONGODB_KEYFILE_VALUE  ]] || usage "MONGODB_KEYFILE_VALUE have to be set"
  fi
}

# Can export CREATE_USER=1 to indicate that variables for optional user
# are provided
check_env_vars
