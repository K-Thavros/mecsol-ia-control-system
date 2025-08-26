#!/bin/bash
# ==============================================================================
# MECSOL AI Control System - Deployment Script
# ==============================================================================
#
# This script automates the installation and launch of the MECSOL AI stack.
# It performs the following actions:
#   1. Verifies that Docker and Docker Compose are installed.
#   2. Builds and launches the Docker containers in detached mode.
#
# ==============================================================================

# --- Color Definitions ---
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_RESET='\033[0m'

# --- Helper Functions ---

# Prints an error message and exits the script.
function error_exit() {
    echo -e "${COLOR_RED}❌ ERROR: $1${COLOR_RESET}"
    echo -e "${COLOR_RED}Deployment aborted.${COLOR_RESET}"
    exit 1
}

# Prints a success message.
function success_message() {
    echo -e "${COLOR_GREEN}✅ SUCCESS: $1${COLOR_RESET}"
}

# Prints an informational message.
function info_message() {
    echo -e "${COLOR_BLUE}ℹ️  $1${COLOR_RESET}"
}

# Prints a warning message.
function warn_message() {
    echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}"
}

# --- Main Functions ---

function welcome_message() {
    echo -e "${COLOR_BLUE}===============================================${COLOR_RESET}"
    echo -e "${COLOR_BLUE}  MECSOL AI Control System - Deployment Start  ${COLOR_RESET}"
    echo -e "${COLOR_BLUE}===============================================${COLOR_RESET}"
    echo ""
}

# Checks for Docker and Docker Compose dependencies.
function check_dependencies() {
    info_message "Verifying dependencies..."

    # Check for Docker
    if ! command -v docker &> /dev/null; then
        error_exit "Docker is not installed. Please install it before running this script.\nOn Ubuntu/Debian, you can run: \n'sudo apt-get update && sudo apt-get install docker.io'"
    fi

    # Check for Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error_exit "Docker Compose is not installed. Please install it before running this script.\nOn Ubuntu/Debian, you can run: \n'sudo apt-get update && sudo apt-get install docker-compose'"
    fi

    success_message "Docker and Docker Compose are installed."
    echo ""
}

# Builds and launches the application using Docker Compose.
function launch_application() {
    info_message "Launching the MECSOL AI application stack..."
    echo "This may take several minutes the first time as images are built."
    
    docker-compose up -d --build
    
    # Check the exit code of the docker-compose command
    if [ $? -ne 0 ]; then
        error_exit "Docker Compose failed to start the services. Please check the output above for errors."
    fi
}

function final_confirmation() {
    echo ""
    echo -e "${COLOR_GREEN}=====================================================================${COLOR_RESET}"
    echo -e "${COLOR_GREEN}     🚀 MECSOL AI System Deployed Successfully! 🚀               ${COLOR_RESET}"
    echo -e "${COLOR_GREEN}=====================================================================${COLOR_RESET}"
    echo ""
    info_message "The application stack is running in the background."
    info_message "The dashboard should now be accessible at your server's IP address or domain."
    echo ""
    warn_message "If you encounter any issues, check the service logs by running:"
    echo -e "  ${COLOR_YELLOW}docker-compose logs -f${COLOR_RESET}"
    echo ""
    info_message "To stop the application, run: 'docker-compose down'"
    echo ""
}

# --- Script Execution ---
function main() {
    welcome_message
    check_dependencies
    launch_application
    final_confirmation
}

main
