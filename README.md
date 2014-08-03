# Docker and Zend Framework 2

Here you'll find a `Dockerfile` and some configurations to run your Zend Framework 2 applications
within a docker container.  
Currently it's main purpose is to quickly start developing an ZF2 app, it's not for production use.


## Running your ZF2 app in docker

Run your docker container and adjust `/home/user/git/your-zf2-app` to match the
local path to your ZF2 Application root.

```bash
sudo docker run -d -p 8080:80 \
        -v /home/user/your-zf2-app:/zf2-app maglnet/docker-zf2
```

### Example with ZF2 Skeleton Application

```bash
mkdir zend-skeleton
curl -s https://getcomposer.org/installer | php --
php composer.phar create-project \
        -sdev --repository-url="https://packages.zendframework.com" \
        zendframework/skeleton-application zend-framework-skeleton
cd zend-framework-skeleton
sudo docker run -d -p 8080:80 -v $(pwd):/zf2-app maglnet/docker-zf2
```
Now visit http://localhost:8080 and check out your running Zend Skeleton Application
