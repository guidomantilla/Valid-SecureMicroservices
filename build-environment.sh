echo "" && echo "##### LIMPIANDO AMBIENTE DOCKER LOCAL #####" && echo ""
docker container rm --force valid-mysql
docker container rm --force valid-oauth2
docker container rm --force valid-movies
docker container rm --force valid-web
docker network rm valid-network

echo "" && echo "##### DESCARGANDO PROYECTOS GITHUB #####" && echo ""
cd ..
WORK_DIR=$PWD

rm -rf valid_mysql-scripts
rm -rf valid_oauth2-server
rm -rf valid_movies-api
rm -rf valid_movies-web

git clone https://github.com/guidomantilla/valid_mysql-scripts.git
echo ""
git clone https://github.com/guidomantilla/valid_oauth2-server.git
echo ""
git clone https://github.com/guidomantilla/valid_movies-api.git
echo ""
git clone https://github.com/guidomantilla/valid_movies-web.git

echo "" && echo "##### PROYECTOS DESCARGADOS: #####"  && echo ""
echo "$(ls -h)"

echo "" && echo "##### CREANDO AMBIENTE DOCKER LOCAL #####"  && echo ""
docker-compose up -d --build
