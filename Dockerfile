# This builder image will not be used at runtime
# See https://docs.docker.com/develop/develop-images/multistage-build/
FROM gradle:6.7.1 as builder

# Copy sourcecode into build image
COPY build.gradle ./app/
COPY src/ ./app/src/
COPY settings.gradle ./

RUN gradle clean build --no-daemon

# Now switch to the runtime image; base it on the latest Java, in a "slim" variant.
FROM adoptopenjdk/openjdk13:debianslim-jre

# Put the one necessary class files, with all dependencies, into the into the runtime.
COPY service-account.json .
COPY --from=builder ./home/gradle/app/build/libs/app.jar .
# Run it
CMD [ "java", "-jar",  "./app.jar" ]