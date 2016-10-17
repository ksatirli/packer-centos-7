#!/usr/bin/env bash

# check if ${1}, ${2} and ${3} are set
if [[ -z "${1}" || -z "${2}" || -z "${3}" ]]
then
  echo
  echo "Missing one or more required positional arguments:"
  echo "  1.) Pass an AWS Profile Identifier as the first argument"
  echo "  2.) Pass an AWS Region Identifier as the second argument"
  echo "  3.) Pass an AMI Image Identifier as the third argument"
  echo
  echo "Example:"
  echo "  ./${0} \"cultivatedops\" \"us-east-1\" \"cltvt-centos-7\""
  exit 1
else
  aws \
    --profile="${1}" \
    --region="${2}" \
    ec2 describe-images \
      --owner "self" \
      --filter "Name=architecture,Values=x86_64" \
      --filter "Name=hypervisor,Values=xen" \
      --filter "Name=image-type,Values=machine" \
      --filters "Name=name,Values=${3}*" \
      --filter "Name=root-device-type,Values=ebs" \
      --filter "Name=state,Values=available" \
  | \
  jq \
    --raw-output \
    --sort-keys \
    ".Images | sort_by(.CreationDate) | reverse | .[0] | { ImageId } | .ImageId"
fi
