# Terraform Single file docker task

This repository contains a single file Terraform configuration to set up a Docker environment with Nginx and a simple application.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [Docker](https://docs.docker.com/get-docker/) installed

## Terraform Configuration

The Terraform configuration includes the following resources:

1. **Docker Network**: Creates a Docker network named `myapp_network`.
2. **Docker Images**: Pulls the latest images for Nginx and a simple app (`hashicorp/http-echo`).
3. **Docker Containers**: 
   - Runs the app container on port 5678 with the command `-text "hello world!!!"`.
   - Runs the Nginx container on port 443 with a custom Nginx configuration.
4. **Local File**: Generates an Nginx configuration file.
5. **Output**: Outputs the IP address of the Nginx container.
6. **Null Resource**: Triggers when the nginx ip is available and updates the `/etc/hosts` file on the host with the Nginx container's IP address and hostname.

## Usage

1. Clone this repository:
    ```sh
    git clone git@github.com:doronfe/single_file_terraform.git
    cd single_file_terraform/
    ```

2. Initialize Terraform:
    ```sh
    terraform init
    ```

3. Apply the Terraform configuration:
    ```sh
    terraform fmt
    terraform validate
    terraform plan
    terraform apply --auto-approve
    ```

4. Access the application:
    - Open your browser and navigate to `https://myapp.local`.

## Cleanup

To destroy the Terraform-managed infrastructure, run:
```sh
terraform destroy --auto-approve
