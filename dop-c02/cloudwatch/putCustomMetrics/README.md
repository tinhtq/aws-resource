# Put Custom Metrics to AWS Cloudwatch Logs
```bash
aws cloudwatch put-metric-data --metric-name Buffers --namespace MynammeSpace --unit Bytes --value 231434333 --dimensions InstanceID=1-234566789,InstanceType=m1.small
```