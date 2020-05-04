# Technical Scope
The scope for this project is:

Create an web application that:
1. Allows an User to Login
2. Allows an User to Logout
3. Shows some information on-screen. This information must come from a backend application
4. Security is a **must**
5. Spring Framework is **bonus**
6. Microservices principles is a **bonus**

# Technical Documentation

## Dictionary

For this project, the following definitions are made:
* **System**: The hole project scope. This project will consist of 4 applications.
* **Application**: One logical deployment unit that allocates a logical set of related responsabilities.


## Architecture
This project architecture consists of 4 applications like this.

* **Mysql Database**: For storing business and security data
* **Oauth2 Server**: For application and user authentication, also for user authorization.
* **API Server**: For exposing business data
* **Web App**: For UI presentation

### Mysql Database
This database will store business and security data. However, each data category will be store in different schemas, following the [Schema-per-Service Pattern](https://microservices.io/patterns/data/database-per-service.html).

#### valid-security schema

* **oauth_client_details**: This table will store application-level credentials, following OAUTH2 guidelines. So this table for application-level **Authentication**.
![Image 1](img/oauth_client_details.png)

    The most relevant columns are:
    * **client_id**: A client application "username"
    * **client_secret**: A client application "password". This password will be stored as a hash, using [bcrypt algorithm](https://en.wikipedia.org/wiki/Bcrypt)

* **users**: This table will store end-user-level credentials. So this table for end-user-level **Authentication**.
![Image 1](img/users.png)

    The most relevant columns are:
    * **username**: A end-user username
    * **password**: A end-user password. This password will be stored as a hash, using [bcrypt algorithm](https://en.wikipedia.org/wiki/Bcrypt)

* **authorities**: This table will store end-user-level permissions. So this table for end-user-level **Authorization**.
![Image 1](img/authorities.png)


#### valid-movie-rental schema

* **films**: This table will store the movies inventory. Business data.
![Image 1](img/films.png)

#### Disclaimer

The **films** table comes from [Sakila sample database](https://dev.mysql.com/doc/sakila/en/)

The **users** and **authorities** tables come from [Spring Security database schemas](https://docs.spring.io/spring-security/site/docs/5.0.x/reference/html/appendix-schema.html)


### Oauth2 Server
This app will focus on **Authentication** and **Authorization**. Both applications and users will authenticate with this application. Furthermore, users will be authorized here. 

This application will access the **valid-security schema** for these propuses. 

For all of this, `Spring Security` from `Spring Framework` is used. The most relevante `Gradle` information are:

```gradle
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'

    implementation 'org.springframework.cloud:spring-cloud-starter-security'
    implementation 'org.springframework.security.oauth.boot:spring-security-oauth2-autoconfigure'
```
Having the **Authentication** and **Authorization** isolated from the rest of the system, is an implementation of the [Microservices Pattern](https://microservices.io/patterns/microservices.html).


#### How the Authentication and Authorization works?
This application follows OAUTH2 Guidelines combined with JWT. For that, a RSA keystore is used (`jwt.jks`) and the application exposes the `/oauth/token` route. This URI will execute the Authentication and Authorization describe above. This URI can be invoked, using the following `curl` command.
```bash
curl --location --request POST 'https://localhost:7443/oauth/token' \
--header 'Authorization: Basic VkFMSURfTU9WSUVfUkVOVEFMX1dFQjpWQUxJRF9NT1ZJRV9SRU5UQUxfV0VC' \
--form 'grant_type=password' \
--form 'username=Admin' \
--form 'password=password'
```
For more details regarding this usage, check this [postman project](postman/valid_oauth2-server.postman_collection.json).

Notice that the URI is secure using `HTTPS` . For this, a RSA keystore is used (`ssl.p12`).

A client application  will use the URI with `Basic` authentication passing it's credentials in the `header`. This credendials will be compared with the information store in the database.
```sql
select client_id, client_secret from valid-security.oauth_client_details;
```

Also, the client application will provide the end-user username and password in the `form` space for that. This credendials will be compared with the information store in the database.
```sql
select username, password from valid-security.users;
```

For a request, use the `curl` from command above. The response will be something like this:
```json
{
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiVVNFUl9DTElFTlRfUkVTT1VSQ0UiLCJVU0VSX0FETUlOX1JFU09VUkNFIl0sInVzZXJfbmFtZSI6IkFkbWluIiwic2NvcGUiOlsicm9sZV9hZG1pbiJdLCJleHAiOjE1ODg1NDAyNTMsImF1dGhvcml0aWVzIjpbInJvbGVfYWRtaW4iXSwianRpIjoiMzRiMzUwNjgtZGM0YS00ZmVmLWE5ZmYtY2RlYzU5ZTBkYTViIiwiY2xpZW50X2lkIjoiVkFMSURfTU9WSUVfUkVOVEFMX1dFQiJ9.TI2q3Kzjg4FDVZ2uTTt1bIjC14HEhIbTXc4ElkFzqbH2mlbm9Nsty_RKSKiSW-cPWL2AJfH7dqiRhxQ1477XW_TShsfSpODJTYIgcZtdJVciYVz9-rZSDF2G296BWCRAFQKG9l6vxejPLLO9b70eEww9L6A-0o7AfQDTTAVZ8v5ddZBcByJ9tZQuJZbuOchDbLqTMawDJHfcQjaNBOEkgt0PjrKn07iEHIUyd697PyQDi9FF6KnsJ_hWjhn34g7DulBTmuEMYMj8ghs6rgOx2QnAJufSh8B-WueaH-6OZV3Wpow1sMFWoaeJ0JRZl97kU8nGHbtRBjYwNc5cDYp0tg",
    ...
}
```
For this project, the most relevant json field is `access_token`. This token **must** be used as an authorization mechanism for invoking the API URI later on.


