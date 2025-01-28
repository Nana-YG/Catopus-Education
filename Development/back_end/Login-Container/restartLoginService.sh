#!/bin/bash

# 设置默认的容器名称
CONTAINER_NAME="csrm-login"

# 检查是否有同名容器正在运行
EXISTING_CONTAINER=$(docker ps -aq -f name=$CONTAINER_NAME)

if [[ -n "$EXISTING_CONTAINER" ]]; then
    echo "Stopping and removing the existing container '$CONTAINER_NAME'..."
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME
fi

# 构建镜像
echo "Building the Docker image..."
docker build -t $CONTAINER_NAME .

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to build the Docker image."
    exit 1
fi

# 启动容器
echo "Starting the Docker container '$CONTAINER_NAME'..."
docker run -d --name $CONTAINER_NAME $CONTAINER_NAME

if [[ $? -eq 0 ]]; then
    echo "Docker container '$CONTAINER_NAME' restarted successfully."
else
    echo "Error: Failed to restart the Docker container."
    exit 1
fi
