# Stage 1: Build stage to install Flyway and Amazon Corretto JDK
FROM alpine:3.14 AS build

# Install dependencies
RUN apk add --no-cache tar gzip curl

# Install Amazon Corretto JDK
RUN curl -L -o amazon-corretto-11-x64-linux-jdk.tar.gz https://corretto.aws/downloads/resources/11.0.12.7.1/amazon-corretto-11.0.12.7.1-linux-x64.tar.gz \
    && mkdir -p /usr/lib/jvm \
    && tar -xzf amazon-corretto-11-x64-linux-jdk.tar.gz -C /usr/lib/jvm \
    && rm amazon-corretto-11-x64-linux-jdk.tar.gz

# Create the directory for Flyway
RUN mkdir -p /flyway

# Install Flyway
RUN curl -L -o flyway-commandline.tar.gz https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/7.11.4/flyway-commandline-7.11.4-linux-x64.tar.gz \
    && tar -xzvf flyway-commandline.tar.gz -C /flyway/ \
    && rm flyway-commandline.tar.gz \
    && mv /flyway/flyway-7.11.4 /flyway/flyway \
    && chmod +x /flyway/flyway/flyway

# Stage 2: Lambda Python image
FROM public.ecr.aws/lambda/python:3.12

# Copy Amazon Corretto JDK from build stage
COPY --from=build /usr/lib/jvm /usr/lib/jvm

# Copy Flyway from build stage
COPY --from=build /flyway/flyway /var/task/flyway

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/amazon-corretto-11.0.12.7.1-linux-x64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install necessary Python dependencies
COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install -r requirements.txt

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}

# Copy Flyway migrations
COPY db/migrations /var/task/db/migrations

CMD ["app.lambda_handler"]
