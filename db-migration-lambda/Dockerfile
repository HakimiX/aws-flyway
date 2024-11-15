# Use the AdoptOpenJDK base image which supports ARM architecture
FROM adoptopenjdk:11-jre-hotspot-bionic AS java-base

FROM flyway/flyway:9.15.1 AS flyway-builder

# Lambda runtime image
FROM public.ecr.aws/lambda/python:3.12

COPY --from=java-base /opt/java/openjdk /opt/java/openjdk

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

COPY --from=flyway-builder /flyway /flyway

ENV PATH="/flyway:${PATH}"

WORKDIR /var/task

COPY . .

RUN pip install -r requirements.txt

CMD ["app.lambda_handler"]