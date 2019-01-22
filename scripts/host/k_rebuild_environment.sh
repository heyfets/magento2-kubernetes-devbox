#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"

## TODO: Add status messages
cd "${vagrant_dir}/scripts" && eval $(minikube docker-env) && docker build -t magento2-monolith:dev -f ../etc/docker/monolith/Dockerfile ../scripts
cd "${vagrant_dir}/scripts" && eval $(minikube docker-env) && docker build -t magento2-monolith:dev-xdebug -f ../etc/docker/monolith-with-xdebug/Dockerfile ../scripts

# TODO: Repeat for other deployments, not just Magento 2
# See https://github.com/kubernetes/kubernetes/issues/33664#issuecomment-386661882


# TODO: Delete does not work when no releases created yet
cd "${vagrant_dir}/etc/helm"
helm list -q | xargs helm delete
set +e && helm del --purge magento2 2>/dev/null && set -e

# TODO: Need to make sure all resources have been successfully deleted before the attempt of recreating them
sleep 7

cd "${vagrant_dir}/etc/helm" && helm install \
    --name magento2 \
    --values values.yaml \
    --set global.monolith.volumeHostPath="${vagrant_dir}" \
    --set global.checkout.volumeHostPath="${vagrant_dir}" .

# TODO: Waiting for containers to initialize before proceeding
sleep 7


## Bypass Helm
#cd "${vagrant_dir}" && python local_deploy.py --all --ingress \
#    && kubectl patch deployment magento2-monolith -p \
#  "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"

exit 0
