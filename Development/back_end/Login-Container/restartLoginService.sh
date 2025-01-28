#!/bin/bash

# 设置默认的容器名称
CONTAINER_NAME="csrm-login"
NETWORK_NAME="back_end_csrm-network"

# 检查是否有同名容器（无论是否在运行）
EXISTING_CONTAINER=$(docker ps -aq -f name=$CONTAINER_NAME)

if [[ -n "$EXISTING_CONTAINER" ]]; then
    echo "Stopping and removing the existing container '$CONTAINER_NAME'..."
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME
fi

# 检查网络是否存在
EXISTING_NETWORK=$(docker network ls -q -f name=$NETWORK_NAME)

if [[ -z "$EXISTING_NETWORK" ]]; then
    echo "Creating Docker network '$NETWORK_NAME'..."
    docker network create $NETWORK_NAME
fi

# 构建镜像
echo "Building the Docker image..."
docker build -t $CONTAINER_NAME .

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to build the Docker image."
    exit 1
fi

# 启动容器并连接到网络
echo "Starting the Docker container '$CONTAINER_NAME' on network '$NETWORK_NAME'..."
docker run -d --name $CONTAINER_NAME --network $NETWORK_NAME $CONTAINER_NAME

if [[ $? -eq 0 ]]; then
    echo "Docker container '$CONTAINER_NAME' started successfully on network '$NETWORK_NAME'."
else
    echo "Error: Failed to start the Docker container."
    exit 1
fi
