docker stop csrm-login
docker stop csrm-content
docker stop csrm-database
docker stop csrm-nginx
docker rm csrm-login
docker rm csrm-content
docker rm csrm-database
docker rm csrm-nginx
docker compose build
docker compose up -d
docker compose logs -f csrm-nginx
