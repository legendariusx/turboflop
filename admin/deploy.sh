docker build . -t turboflop/admin
docker stop turboflop-admin
docker rm turboflop-admin
docker run -d -p 8080:8080 --name turboflop-admin --restart=always turboflop/admin:latest
