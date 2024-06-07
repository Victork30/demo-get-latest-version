# demo-get-latest-version
This is an exercise project. This project represents a small Python application with infrastructure as a code deployment

To chech if nginx container can access to the python container, run:
```
docker-compose exec nginx curl http://app:8080/nginx/agent -I
```
If status is 200, it works as it should.
