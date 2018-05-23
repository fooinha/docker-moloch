# docker-moloch
Docker for moloch demo  - local elasticsearch




```
docker build --tag moloch:latest .

docker run -t --net bridge --privileged -p 3128:3128 -p 8005:8005 --name moloch-demo moloch:latest

docker start moloch-demo
```

Includes a Squid proxy cache service at port 3218.

Configure your proxy to localhost:3128

Go to http://localhost:8005 and see information about packets, flows and sessions in moloch's ui.
