# -------------------------------------
FROM debian:stable-slim as download-and-extract
ARG GIT_COMMIT=master
RUN apt-get update && apt-get install -y wget
RUN wget https://github.com/ControlSystemStudio/phoebus/archive/$GIT_COMMIT.tar.gz
RUN tar -xf $GIT_COMMIT.tar.gz
RUN mv /phoebus-$GIT_COMMIT* /phoebus-src

# -------------------------------------
FROM openjdk:11-buster as builder
RUN apt-get update && apt-get install -y maven # openjfx libopenjfx-jni libopenjfx-java
COPY --from=download-and-extract /phoebus-src /phoebus-src
WORKDIR /phoebus-src
RUN mvn clean verify -f dependencies/pom.xml
# Instead of compiling all phoebus modules using:
#RUN mvn -DskipTests clean install
# we only compile the service-archive-engine and its dependencies:
RUN mvn -DskipTests --projects :service-archive-engine --also-make clean install

# -------------------------------------
FROM openjdk:11-buster as final
ARG GIT_COMMIT=master
LABEL git_commit=$GIT_COMMIT
COPY --from=builder /phoebus-src/services/archive-engine/target /phoebus-archive-engine
WORKDIR /phoebus-archive-engine
# assert that all dependencies can be resolved:
RUN jdeps --class-path './lib/*' --recursive service-archive-engine-4.6.6-SNAPSHOT.jar | (! grep 'not found')
ENTRYPOINT ["java", "-jar", "./service-archive-engine-4.6.6-SNAPSHOT.jar"]
CMD ["-help"]
