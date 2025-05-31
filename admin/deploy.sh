docker build . -t turboflop/turboflop-web
docker stop turboflop-web
docker rm turboflop-web
docker run -d -p 8080:8080 --name turboflop-web --restart=always turboflop/turboflop-web:latest
