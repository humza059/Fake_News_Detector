# How to Run with Docker

This guide explains how to run the Fake News Detector application using Docker. This is the easiest way to share and run the app on any machine.

## Prerequisites
1.  **Install Docker Desktop**: Download and install Docker Desktop for your OS (Windows, Mac, or Linux) from [docker.com](https://www.docker.com/products/docker-desktop).
2.  **Start Docker**: Make sure Docker Desktop is running.

## Running the App

1.  Open a terminal (Command Prompt, PowerShell, or Terminal) in the project folder.
2.  Run the following command:

    ```bash
    docker-compose up -d --build
    ```

    *   `up`: Starts the containers.
    *   `-d`: Runs them in "detached" mode (background).
    *   `--build`: Forces a rebuild of the images to ensure you have the latest code.

3.  Wait for the process to complete (it may take a few minutes the first time).

## Accessing the App

*   **Frontend (Web App)**: Open your browser and go to `http://localhost:8080`
*   **Backend (API)**: The API is running at `http://localhost:8001` (e.g., docs at `http://localhost:8001/docs`)

## Stopping the App

To stop the containers, run:

```bash
docker-compose down
```
