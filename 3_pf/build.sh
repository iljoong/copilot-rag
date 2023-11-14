#! /bin/bash

set -e

program_name=$0

function usage {
    echo "usage: $program_name [-i|-image_tag|--image_tag]"
    echo "  -i|-image_tag|--image_tag                     specify container image tag"
    echo "  -r|-registry|--registry                       specify container registry name, for example 'xx.azurecr.io'"
    echo "  -n|-name|--name                               specify app name to produce a unique FQDN as AppName.azurewebsites.net."
    echo "  -l|-location|--location                       specify app location, default to 'centralus'"
    echo "  -sku|--sku                                    specify app sku, default to 'F1'(free)"
    echo "  -g|-resource_group|--resource_group           specify app resource group"
    echo "  -subscription|--subscription                  specify app subscription, default using az account subscription"
    echo "  -v|-verbose|--verbose                         specify verbose mode"
    echo "  -p|-path|--path                               specify folder path to be deployed"
    exit 1
}
if [ "$1" == "-help" ] || [ "$1" == "-h" ]; then
  usage
  exit 0
fi

location="eastus"
sku="F1"
verbose=false

####################### Parse and validate args ############################
while [ $# -gt 0 ]; do
  case "$1" in
    -i|-image_tag|--image_tag)
      image_tag="$2"
      ;;
    -r|-registry|--registry)
      registry_name="$2"
      ;;
    -n|-name|--name)
      name="$2"
      ;;
    -l|-location|--location)
      location="$2"
      ;;
    -sku|--sku)
      sku="$2"
      ;;
    -g|-resource_group|--resource_group)
      resource_group="$2"
      ;;
    -subscription|--subscription)
      subscription="$2"
      ;;
    -v|-verbose|--verbose)
      verbose=true
      ;;
    -p|-path|--path)
      path="$2"
      ;;
    *)
    printf "***************************\n"
    printf "* Error: Invalid argument.*\n"
    printf "***************************\n"
    exit 1
  esac
  shift
  shift
done

# fail if image_tag not provided
if [ -z "$image_tag" ]; then
    printf "***************************\n"
    printf "* Error: image_tag is required.*\n"
    printf "***************************\n"
    exit 1
fi

# check if : in image_tag
if [[ $image_tag == *":"* ]]; then
    echo "image_tag: $image_tag"
else
    version="v$(date '+%Y%m%d-%H%M%S')"

    image_tag="$image_tag:$version"
    echo "image_tag: $image_tag"
fi

# fail if registry_name not provided
if [ -z "$registry_name" ]; then
    printf "***************************\n"
    printf "* Error: registry is required.*\n"
    printf "***************************\n"
fi

# fail if name not provided
if [ -z "$name" ]; then
    printf "***************************\n"
    printf "* Error: name is required.*\n"
    printf "***************************\n"
fi

# fail if resource_group not provided
if [ -z "$resource_group" ]; then
    printf "***************************\n"
    printf "* Error: resource_group is required.*\n"
    printf "***************************\n"
fi

# fail if path not provided
if [ -z "$path" ]; then
    printf "***************************\n"
    printf "* Error: path is required.*\n"
    printf "***************************\n"
    exit 1
fi

####################### Build and push image ############################
echo "Change working directory to $path"
cd "$path"
docker build -t "$image_tag" .

if [[ $registry_name == *"azurecr.io" ]]; then
    echo "Trying to login to $registry_name..."
    #az acr login -n "$registry_name"

    acr_image_tag=$registry_name/$image_tag
    echo "ACR image tag: $acr_image_tag"
    docker tag "$image_tag" "$acr_image_tag"
    image_tag=$acr_image_tag
else
    echo "Make sure you have docker account login!!!"
    printf "***************************************************\n"
    printf "* WARN: Make sure you have docker account login!!!*\n"
    printf "***************************************************\n"

    docker_image_tag=$registry_name/$image_tag

    echo "Docker image tag: $docker_image_tag"
    docker tag "$image_tag" "$docker_image_tag"
    image_tag=$docker_image_tag
fi

#echo "Start pushing image...$image_tag"
#docker push "$image_tag"

####################### Create and config app ############################

function append_to_command {
  command=$1
  if [ -n "$subscription" ]; then
    command="$command --subscription $subscription"
  fi
  if $verbose; then
    command="$command --debug"
  fi
  echo "$command"
}
