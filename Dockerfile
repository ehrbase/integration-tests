# Use the desired base image
FROM python:3.11.9-slim-bullseye

# Set the working directory
WORKDIR /integration-tests

# copy support scripts
COPY --chmod=755 ./scripts/collectRebotResults.sh /bin/collectRebotResults
COPY --chmod=755 ./scripts/runRobotTest.sh /bin/runRobotTest

# Copy the rest of the project files to the working directory
COPY ./tests ./tests

# install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN mv ./tests/requirements.txt ./requirements.txt && \
    pip install --no-cache-dir -r requirements.txt
