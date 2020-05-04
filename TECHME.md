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

For all of this, `Spring Security` from `Spring Framework` is used. The most relevant `Gradle` information are:

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

### API Server
This application will focus on handling the interaction with the database (reads and writes) for business data. It will access the **valid-movie-rental schema** for these propuses. 

For all of this, `Spring Data Rest` and `Spring Security` from `Spring Framework` is used. The most relevant `Gradle` information are:

```gradle
	implementation 'org.springframework.boot:spring-boot-starter-web'
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'org.springframework.boot:spring-boot-starter-data-rest'

	implementation 'org.springframework.cloud:spring-cloud-starter-security'
	implementation 'org.springframework.cloud:spring-cloud-starter-oauth2'
```

This application exposes many URI's. However due this project's scope, the URI that matter is `https://localhost:7444/films`. This URI can be invoked, using the following `curl` command.
```bash
curl --location --request GET 'https://localhost:7444/films' \
--header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiVVNFUl9DTElFTlRfUkVTT1VSQ0UiLCJVU0VSX0FETUlOX1JFU09VUkNFIl0sInVzZXJfbmFtZSI6IkFkbWluIiwic2NvcGUiOlsicm9sZV9hZG1pbiJdLCJleHAiOjE1ODg1NTU5OTIsImF1dGhvcml0aWVzIjpbInJvbGVfYWRtaW4iXSwianRpIjoiMjk2MmYzYzctODQwYy00OWJkLThkZjctMmU2OTQ3YTQ2OWM0IiwiY2xpZW50X2lkIjoiVkFMSURfTU9WSUVfUkVOVEFMX1dFQiJ9.Jm8uMdHMc-sL6FEDvSV5tbHZbbn2ygxTxCvXRZw5lvWDBmda-5tSV-aGzUQiE_qcCdIeza5iQr-2xq58eqF2Ukq0DfvzOx4A5h55neFsMGUQhTgWgQ54eQMAMIQOMRhyVprmrja1-YKy54LuRkAWa8_NQv-SAT4j3MZzzdALwEkSC0JGKJhwad30aqcRCam3WRr-nJ04xBiSrAwTOnKTl8m9n3AQTZ4lUkdozzPJp3S3m3QTJRUFtH93_UxDyke3QJDfAtFwfXEL0cW0cTMijTXsGnIF_xEKt7betCNppq_2ESo8MBOxbmwl2nuB1inmbD3nhK-mplg4l-2rXw05XA'
```
For more details regarding this usage, check this [postman project](postman/valid_movies-api.postman_collection.json).

Notice that the URI is secure using `HTTPS` . For this, a RSA keystore is used (`ssl.p12`).

A client application  will use the URI with `Bearer` authentication passing the `access_token` retreived from the OAuth2 Server in the header. This token's signature will be compared with the public key from the OAuth2 Server.

For a request, use the `curl` from command above. The response will be something like this:
```json
{
  "_embedded": {
    "filmses": [
      {
        "title": "ACADEMY DINOSAUR",
        "description": "A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies",
        "category": "Documentary",
        "price": 0.99,
        "length": 86,
        "rating": "PG",
        "actors": "Christian Gable, Mary Keitel, Lucille Tracy, Sandra Peck, Johnny Cage, Mena Temple, Warren Nolte, Oprah Kilmer, Penelope Guiness, Rock Dukakis",
        "_links": {
          "self": {
            "href": "https://localhost:7444/films/1"
          },
          "films": {
            "href": "https://localhost:7444/films/1"
          }
        }
      }
...
    ]
  },
  "_links": {
    "first": {
      "href": "https://localhost:7444/films?page=0&size=20"
    },
    "self": {
      "href": "https://localhost:7444/films{?page,size,sort}",
      "templated": true
    },
    "next": {
      "href": "https://localhost:7444/films?page=1&size=20"
    },
    "last": {
      "href": "https://localhost:7444/films?page=49&size=20"
    },
    "profile": {
      "href": "https://localhost:7444/profile/films"
    }
  },
  "page": {
    "size": 20,
    "totalElements": 997,
    "totalPages": 50,
    "number": 0
  }
}
```

### Web App
This application is a legacy web app build with `Spring MVC` and `Spring Security` from `Spring Framework`.

The most relevant `Gradle` information are:

```Gradle
 implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'
    implementation 'org.thymeleaf.extras:thymeleaf-extras-springsecurity5'

    implementation 'org.springframework.security:spring-security-jwt:1.0.9.RELEASE'
    implementation 'com.jayway.jsonpath:json-path:2.4.0'

    implementation 'com.squareup.okhttp3:okhttp'
    implementation 'org.apache.httpcomponents:httpclient'
```
As described [here](README.md), this project only consists of 3 uses cases:
* Login
* Logout
* Show a movies list

#### Login Use Case
When the user logs in, the web application will call the OAuth2 Servers endpoint `https://localhost:7443/oauth/token`, passing the client application credentials, and the user's credentials.

If both credentials are OK, as a response, the OAuth2 Server will return an `access_token`. With this, the web application will create a session in memory and will allow the user interact with the application given the authorities returned in the `access_token`.

Then the user is redirected to the home page.

#### Show a movies list
When the user goes to the home page, the application will call the API Server endpoint `https://localhost:7444/films` passing the `access_token` from above. 

If the `access_token` is valid, as a response, the API Server will return a list of movies.

This movies set will rendered into the home page.

#### Logout Use Case
When the user logs out, the web application will destroy the in-memory session and invalidate the cookies sent to the browser.

Then the user is redirected to the Login page `https://localhost:7445/`.

Notice that the URI is secure using `HTTPS` . For this, a RSA keystore is used (`ssl.p12`).


## Security Concerns
The security implemented in this project consist of:

1. **Secure transportation layer communication between the servers**: All comunication between the servers uses HTTPS protocol with RSA keystore for asymmetric cryptography.

    **Note**: The comunication with the database is insecure. Does not implement any security at transportation layer. 

2. **Secure authentication and authorization communication between the servers**: All comunication between the servers uses credentials (or credential-based generated tokens).

    **Note**: The comunication with the database is "secure". Both, OAuth2 Server and API Server uses the `root` credentials for accesing the database.

3. **Isolated network for communication between the servers**: All servers are attached to and isolated doker-network. Other components in another docker-nerwotk can't access the servers from this project.
**Note**: The only weakness is that all servers are bridged with the `host`, for development porpuses. This open-door can be close just by creating the containers without any `port-mapping`.

4. **Secured Credentials**: All credentials are stored using [bcrypt algorithm](https://en.wikipedia.org/wiki/Bcrypt). All credentials handling are delegated to `Spring Security`.

    **Note**: The database `root` credentials and the web application `client_secret` are hard-coded in the `application.yml` file. This is a technical debt, the best practice is to storage and retrieve this credentials from an external component.

5. **CORS disabled and CSRF enabled**: Following simple-legacy best practices, the `Cross-origin resource sharing` support is disabled. Also the `Cross-site request forgery` protection is enabled.



