#!/bin/bash

#github action release.sh

set -euo pipefail

image=${1:?Usage: bash release.sh <image>}

ver=$(cat version)
echo "当前版本 $ver"

rm -rf artifact-dist
mkdir artifact-dist

function archive() {
  local arch=$1
  #echo "整理部署文件 $arch"
  local arch_name=${arch//\//-}
  echo $arch_name

  local deploy="anylink-$ver-$arch_name"
  local container_id
  container_id=$(docker container create --pull=always --platform "$arch" "$image")
  rm -rf anylink-deploy
  docker cp -a "$container_id:/app" ./anylink-deploy
  docker container rm "$container_id"

  ls -lh anylink-deploy

  tar zcf "${deploy}.tar.gz" anylink-deploy
  mv "${deploy}.tar.gz" artifact-dist/
}

echo "copy二进制文件"

archive "linux/amd64"
archive "linux/arm64"

ls -lh artifact-dist

#注意使用root权限运行
#cd anylink-deploy
#sudo ./anylink --conf="conf/server.toml"
