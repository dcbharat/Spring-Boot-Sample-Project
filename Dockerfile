# Stage 1: Build
FROM openjdk:8-jdk-slim AS build
WORKDIR /workspace/app

# Copy Maven wrapper and project files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Build the project
RUN ./mvnw clean package -DskipTests

# Extract dependency jars
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# Stage 2: Run
FROM openjdk:8-jdk-slim
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/target/dependency

# Copy app and dependencies
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# Set entrypoint
ENTRYPOINT ["java","-cp","app:app/lib/*","com.demo.bankapp.BankApplication"]
