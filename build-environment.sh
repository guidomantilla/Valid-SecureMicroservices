echo "" && echo "##### LIMPIANDO AMBIENTE DOCKER LOCAL #####" && echo ""
docker container rm --force valid_mysql
docker container rm --force valid_oauth2
docker network rm valid_network

echo "" && echo "##### DESCARGANDO PROYECTOS GITHUB #####" && echo ""
cd ..
WORK_DIR=$PWD

rm -rf valid_mysql-scripts
rm -rf valid_oauth2-server

git clone git@github.com:guidomantilla/valid_mysql-scripts.git
git clone git@github.com:guidomantilla/valid_oauth2-server.git

echo "" && echo "##### PROYECTOS DESCARGADOS: #####"  && echo ""
echo "$(ls -h)"


PROJECT_MAIN_FOLDER=$WORK_DIR/Valid-SecureMicroservices
PROJECT_MYSQL_FOLDER=$WORK_DIR/valid_mysql-scripts
PROJECT_OAUTH2_FOLDER=$WORK_DIR/valid_oauth2-server
#PROJECT_CATALOG_FOLDER=$WORK_DIR/valid_catalog-api
#PROJECT_CATALOG_FOLDER=$WORK_DIR/valid_catalog-api


echo "" && echo "##### CREANDO AMBIENTE DOCKER LOCAL #####"  && echo ""
docker network create valid_network

echo "" && echo "----- MYSQL"  && echo ""
cd $PROJECT_MYSQL_FOLDER
sh build.sh valid_mysql 3308

echo "" && echo "----- OAUTH2 SERVER"  && echo ""
cd $PROJECT_OAUTH2_FOLDER
sh build.sh valid_oauth2 8443 valid_mysql


