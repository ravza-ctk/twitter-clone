# Twitter Clone Backend

This is the backend service for the Twitter Clone application, built with **Spring Boot** and **Java**. It provides RESTful APIs for user authentication, tweet management, and social interactions.

## 🛠 Technology Stack

- **Java 17+**
- **Spring Boot 3.x**
- **Spring Security** with **JWT** for Authentication
- **Spring Data JPA** (Hibernate) for Database interaction
- **MySQL / PostgreSQL** (Assumed based on JPA usage)
- **Maven** for dependency management

## 🚀 Getting Started

### Prerequisites
- JDK 17 or higher
- Maven
- MySQL or compatible database running

### Installation

1.  **Clone the repository**
2.  **Configure Database**: Update `src/main/resources/application.properties` with your database credentials.
3.  **Build the project**:
    ```bash
    ./mvnw clean install
    ```
4.  **Run the application**:
    ```bash
    ./mvnw spring-boot:run
    ```
    The server typically runs on `http://localhost:8080`.

## 🔑 Key Endpoints

### Authentication (`/rest/api/auth`)
- `POST /register`: Register a new user.
- `POST /login`: Login and receive a JWT token.

### Tweets (`/rest/api/tweet`)
- `GET /feed`: Get the main feed of tweets.
- `GET /list/{username}`: Get tweets for a specific user.
- `POST /save`: Post a new tweet.
- `POST /like/{id}`: Like/Unlike a tweet.
- `POST /retweet/{id}`: Retweet/Undo retweet.
- `POST /bookmark/{id}`: Bookmark/Remove bookmark.

### User (`/rest/api/user`)
- `GET /me`: Get current user profile.
- `PUT /update`: Update user profile.

## 🔒 Security
The application uses **JWT (JSON Web Token)** for stateless authentication.
- Public endpoints: `/rest/api/auth/**`
- Protected endpoints: All others (require `Authorization: Bearer <token>` header).

## 📂 Project Structure
- `controller`: REST API Controllers
- `service`: Business Logic
- `repository`: Data Access Layer
- `model`: JPA Entities (User, Tweet, Comment, etc.)
- `dto`: Data Transfer Objects for API requests/responses
- `config`: Security and App configurations
