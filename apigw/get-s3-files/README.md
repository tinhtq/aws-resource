# Get S3 files from API Gateway

## Get Bearer Token (ID Token)

aws cognito-idp initiate-auth \
 --auth-flow USER_PASSWORD_AUTH \
 --client-id <client-id> \
 --auth-parameters USERNAME=testuser@example.com,PASSWORD=TempPassword123!
