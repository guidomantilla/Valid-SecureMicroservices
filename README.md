# Valid  Movies Rental
This project was created as part of Valid's Hiring Process ( hope I can get the job :) )

This is a very basic application, with just 3 use cases:
* Login
* Logout
* Show a movies list

This demo is more about backend security.

Maybe, I will create a full feature web application on a near future.

This project is under [Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/)

# Technical Stuff
You will find all the *stuff that matters* (like Martin Fowler will say it) [here](TECHME.md)


# How to build this project?

## Prerequisites
This project was develop and "tested" on an Ubuntu OS, so you will need a linux-based OS for building and running the project using the procedure below.

You will need to free at least 2.5GB of your RAM, just for running.

![Image 1](img/docker.png)

Also, your machine will need:
* Java 8+
* Gradle 5.5+
* Docker 18+
* Git 2.17+

![Image 1](img/prerequisites.png)

## Procedure
1. Create a folder that will hold all the projects. Then we move into that folder.
```bash
mkdir valid-movies-rental-holder
cd valid-movies-rental-holder
```
2. Clone this git repository using either:
```
git@github.com:guidomantilla/Valid-SecureMicroservices
```
or

```
https://github.com/guidomantilla/Valid-SecureMicroservices.git
```
3. Move into new folder

```
cd Valid-SecureMicroservices
```
4. Execute the file

```
sh build-environment.sh
```
5. That's it!! If everything goes well you will have 4 docker containters Up and Running (the ones with the valid-* pattern name) within thier own network (valid-network of course). 

![Image 1](img/docker-status.png)

#### Note: 
You may have the situation where the mysql database container (**valid-mysql**) it's not ready to receive requests yet. So the movies API container (**valid-movies**) and the oauth2 server container (**valid-oauth2**) will have troubles to start.

In this case, wait for a couple of minutes, and the execute:
```
docker container stop valid-oauth2 valid-movies
docker container start valid-oauth2 valid-movies
```

# What just happend? 
In the procedure above, we execute the file 

```
sh build-environment.sh
```
The file executes the following:
1. **Delete local docker environment**: This file will create a docker environment for running and testing this project, and it is expected that you will run this file many times. So, the first thing this file does, is deleting that docker environment. 
```
docker container rm --force valid-mysql
docker container rm --force valid-oauth2
docker container rm --force valid-movies
docker container rm --force valid-web
docker network rm valid-network
```

2. **Delete local git repositories**: The same reasoning from above, but for the local repositories.
```
rm -rf valid_mysql-scripts
rm -rf valid_oauth2-server
rm -rf valid_movies-api
rm -rf valid_movies-web
```

3. **Create local git repositories**.
```
git clone git@github.com:guidomantilla/valid_mysql-scripts.git
git clone git@github.com:guidomantilla/valid_oauth2-server.git
git clone git@github.com:guidomantilla/valid_movies-api.git
git clone git@github.com:guidomantilla/valid_movies-web.git
```

4. **Create local docker environment**: This file will execute a build.sh file that every project has. This build.sh will build the source code and create the docker image locally.  
```
docker network create valid-network
```

* **valid_mysql-scripts git repository**: Here we create the project's database. We specify the docker image and container name and the port where the container will listen for requests.
```
sh build.sh valid-mysql 3308
```

* **valid_oauth2-server git repository**: Here we create the project's OAuth2 Server. We specify the docker image and container name, the port where the container will listen for requests and the mysql database container name.  
```
sh build.sh valid-oauth2 7443 valid-mysql
```

* **valid_movies-api git repository**: Here we create the project's API app. We specify the docker image and container name, the port where the container will listen for requests and the mysql database container name.  

```
sh build.sh valid-movies 7444 valid-mysql
```

* **valid_movies-web git repository**: Here we create the project's Web app. We specify the docker image and container name, the port where the container will listen for requests, the oauth2 server container name and the API container name.
```
sh build.sh valid-web 7445 valid-oauth2 valid-movies
```

# How to use the application?
Once all docker containers are up and running, you can open your browser and enter:
```
https://localhost:7445/
```
Then you can use any of these credentials:
```
user: Admin   password: password
user: Jon     password: password
user: Mike    password: password
```
![Image 1](img/login.png)

Then, the application redirect you to the home screen.

![Image 1](img/home.png)

On the right corner, you will basic a very basic user info. There you will find the logout option.

![Image 1](img/logout.png)

If you enter any invalid URL, the application will show you a 404 page.

![Image 1](img/404.png)