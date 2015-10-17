## [name]
## Run container.
## Params:
##     name: Container Name. Default: "default"
## Example:
##     docker run -p <host_port1>:<container_port1> -p <host_port2>:<container_port2> -i -t DOCKDEV_IMAGE /bin/bash

# docker images
# docker ps

e "Image: $(style bold)${DOCKDEV_IMAGE}"
e "Command: $(style bold)${DOCKDEV_CMD}"

. $SOURCES_PATH/hooks.sh

local cmd="docker run"
local name="$1"

if [ -z "$name" ]; then
  name="$DOCKDEV_CONTAINER_NAME_DEFAULT"
fi

local name_action="${DOCKDEV_IMAGE}.${name}"

# Prepare
_prepare() {
  set_on_exit after_run
  before_run
}

# Run
e "Running $(style bold)${name}$(style normal) [$(style bold)${name_action}$(style normal)]"
if docker ps -a | egrep "\s${name_action}$" > /dev/null
  then
    # Start container
    _prepare
    docker start -i ${name_action}
  else
    # Create container
    if docker images | egrep "^${DOCKDEV_IMAGE}\s" > /dev/null
      then
        # Ports
        if [ ! -z "${DOCKDEV_PORTS}" ]; then
          for port in ${DOCKDEV_PORTS[@]}; do
            cmd="${cmd} -p ${port}"
          done
        fi
        # Mounts
        if [ ! -z "${DOCKDEV_MOUNTS}" ]; then
          for mnt in ${DOCKDEV_MOUNTS[@]}; do
            cmd="${cmd} -v ${mnt}"
          done
        fi
        # Run
        _prepare
        $cmd --name=${name_action} -e "DOCKDEV_NAME=${name_action}" -i -t ${DOCKDEV_IMAGE} #${DOCKDEV_CMD}
      else
        error "Image $(style bold)${DOCKDEV_IMAGE}$(style normal) not found! (run 'bash $0 build'?)"
      fi
  fi