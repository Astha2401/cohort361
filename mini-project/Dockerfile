# Use the official Python base image
FROM python:3.9

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install the required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .

# Expose the port that the Flask app listens on (default is 5000)
EXPOSE 5000

# Start the Flask application
CMD ["python", "app.py"]
