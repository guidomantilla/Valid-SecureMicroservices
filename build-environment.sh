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

PROJECT_MYSQL_FOLDER=$WORK_DIR/valid_mysql-scripts
PROJECT_OAUTH2_FOLDER=$WORK_DIR/valid_oauth2-server
PROJECT_MOVIES_FOLDER=$WORK_DIR/valid_movies-api
PROJECT_WEB_FOLDER=$WORK_DIR/valid_movies-web

echo "" && echo "##### CREANDO AMBIENTE DOCKER LOCAL #####"  && echo ""
docker network create valid-network

echo "" && echo "----- MYSQL"  && echo ""
cd $PROJECT_MYSQL_FOLDER
sh build.sh valid-mysql 3308

echo "" && echo "----- OAUTH2 SERVER"  && echo ""
cd $PROJECT_OAUTH2_FOLDER
sh build.sh valid-oauth2 7443 valid-mysql

echo "" && echo "----- MOVIES API"  && echo ""
cd $PROJECT_MOVIES_FOLDER
sh build.sh valid-movies 7444 valid-mysql

echo "" && echo "----- MOVIES WEB"  && echo ""
cd $PROJECT_WEB_FOLDER
sh build.sh valid-web 7445 valid-oauth2 valid-movies
