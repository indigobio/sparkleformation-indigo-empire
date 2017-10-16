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

del_stack () {
  stack=$1
  run_if_yes "aws cloudformation delete-stack --stack-name $stack"
  echo -n "Waiting for resource deletion"
  while [ "$(aws cloudformation describe-stacks --stack-name $stack --query 'Stacks[].StackStatus' --output text)" == "DELETE_IN_PROGRESS" ]; do
    echo -n .
    sleep 1
  done
  if [ "$(aws cloudformation describe-stacks --stack-name $stack --query 'Stacks[].StackStatus' --output text)" == "DELETE_FAILED" ]; then
    echo "$stack failed to delete"
    exit 1
  fi
}

# Tear down Empire apps
emp apps > /dev/null 2>&1 && : || emp login
for i in $(emp apps | awk '{print $1}') ; do
  run_if_yes "echo $i | emp destroy $i"
done

# Wait for apps to delete
echo -n "Waiting for emp apps to delete"
while [ "$(aws cloudformation list-stacks --stack-status-filter DELETE_IN_PROGRESS --query 'StackSummaries[] | length(@)')" -gt 0 ]; do
  echo -n .
  sleep 1
done
echo

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

del_stack $stack
