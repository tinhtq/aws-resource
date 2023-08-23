#!/bin/bash
# if you need to install the SSM Agent manually:
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# check status ubuntu
sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo snap stop amazon-ssm-agent
# edit the code, id and region in the command below
sudo /snap/amazon-ssm-agent/current/amazon-ssm-agent -register -code "activation-code" -id "activation-id" -region "region" 
sudo snap start amazon-ssm-agent