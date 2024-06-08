# demo-get-latest-version
This is an exercise project. This project represents a small Python application with infrastructure as a code deployment


Project Structure:
* tf - folder contains terraform infrastructure for the project. To install run
```
cd tf
terraform apply
```
* app - folder contains the application itself and some additional components needed to run the application: a bash script "run.sh" to install Docker and docker-compose.yaml to run the project in the Docker environment. 
---

To check if the nginx container can access the python container, connect with ssh to the server and run:
```
docker-compose exec nginx curl http://app:8080/nginx/agent -I
```
If the status is 200, it works as it should. Need to open SSH port to access the server and describe SSH key name first. 
