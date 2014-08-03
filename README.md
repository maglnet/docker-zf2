# Docker and Zend Framework 2

Here you'll find a `Dockerfile` and some configurations to run
your Zend Framework 2 applications within a docker container.  
Currently it's main purpose is to quickly start developing
an ZF2 app, it's not for production use.


## Running your ZF2 application in Docker

Run your docker container and adjust `/home/user/git/your-zf2-app`
to match the local path to your ZF2 Application root.

```bash
cd /home/user/your-zf2-app
sudo docker run -d -p 8080:80 \
        -v $(pwd):/zf2-app maglnet/docker-zf2
```


### Example with ZF2 Skeleton Application

```bash
curl -s https://getcomposer.org/installer | php --
php composer.phar create-project \
        -sdev --repository-url="https://packages.zendframework.com" \
        zendframework/skeleton-application zend-framework-skeleton
cd zend-framework-skeleton
sudo docker run -d -p 8080:80 -v $(pwd):/zf2-app maglnet/docker-zf2
```

Now visit http://localhost:8080 and check out your running
Zend Skeleton Application.


### Example configuration linking to a MySQL container

This requires you to take the following steps:
* Step 1: Start a MySQL Container that will be used by your ZF2 Application
* Step 2: Import your database schema
* Step 3: Start your ZF2 Application Container and link it to the MySQL container
* Step 4: Adjust your ZF2 configuration

**Step 1: Start your MySQL container**

```bash
sudo docker run -P --name zf2-mysql -e MYSQL_ROOT_PASSWORD=mysecretpassword -d mysql
```

**Step 2: Import your database schema**  
Let's first check on which port the MySQL Server is listening
(it's port `49154` in this case):

```bash
# sudo docker ps
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                     NAMES
137ca5116426        mysql:latest        /entrypoint.sh mysql   6 seconds ago       Up 6 seconds        0.0.0.0:49154->3306/tcp   zf2-mysql
```
You can now connect to `localhost:49154` with your favorite MySQL tool and import your schema.


**Step 3: Start your ZF2 application container linked to MySQL**
  
```bash
sudo docker run --name zf2-web --link zf2-mysql:mysql -d -p 8888:80 -v $(pwd):/zf2-app maglnet/docker-zf2
```

**Step 4: Adjust your ZF2 configuration**  
Configure your application to use MySQL User `root` and the password
you used when starting your MySQL container (e.g. `mysecretpassword`)  
**Warning**: *this is not recommended for production environments*

Since IP-Addresses are provided dynamically, you need to get the MySQL containers
IP-Address through `getenv('MYSQL_PORT_3306_TCP_ADDR')`:

```php
return array(
    'db' => array(
        [...]
        'dsn'            => 'mysql:dbname=zf2-tutorial;host=' . getenv('MYSQL_PORT_3306_TCP_ADDR'),
        [...]
);
```
