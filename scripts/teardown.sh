#!/bin/bash -e

run_if_yes () {
  cmd=$1
  echo -n "$cmd [Y/n]? "
  read response
  case $response in
    Y|y)
      eval $cmd
    ;;
    *)
     echo "skipping"
    ;;
  esac
}

# Tear down Empire apps
emp apps > /dev/null 2>&1 && : || emp login
for i in $(emp apps | awk '{print $1}') ; do
  run_if_yes "echo $i | emp destroy $i"
done

# Tear down the custom resources S3 bucket
for bucket in $(aws s3api list-buckets --query 'Buckets[?contains(Name, `customresources`) == `true`].Name' --output text) ; do
  if [ $(aws s3api get-bucket-tagging --bucket $bucket --query 'TagSet[?Key == `Environment`].Value' --output text) == $environment ]; then
    run_if_yes "aws s3 rb --force s3://$bucket"
  fi
done

# Tear down the stack
stack=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE DELETE_FAILED \
  --query 'StackSummaries[].StackId' --output table | grep ${environment}-empire-${AWS_DEFAULT_REGION} \
  | awk '{print $2}')

run_if_yes "aws cloudformation delete-stack --stack-name $stack"
