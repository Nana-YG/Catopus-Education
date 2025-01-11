# Stage 1: Build the application
FROM maven:3.8.7-openjdk-18 AS build

WORKDIR /app

COPY ./Login-Server/pom.xml .
RUN mvn dependency:go-offline

# Compile
COPY ./Login-Server/src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM openjdk:18-jdk-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Start
ENTRYPOINT ["java", "-jar", "app.jar"]
