# Use the desired base image
FROM python:3.11.3

# Set the working directory
WORKDIR /app

# Copy the requirements.txt file to the working directory
COPY tests/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r tests/requirements.txt

# Copy the rest of the project files to the working directory
COPY . .