#!/bin/bash
apt update -y
sudo -u ubuntu bash -c 'curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE=644 sh -'
sudo -u ubuntu bash -c 'curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash'