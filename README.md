# Docker and Zend Framework 2

Here you'll find a `Dockerfile` and some configurations to run
your Zend Framework 2 applications within a docker container.  

Although this image has configurations for production environments included,
it's main purpose is to quickly start developing a ZF2 application.  
If you decide to use this image for setting up a production environment, be sure to excessively test if
your application runs without problems in this environment.

## Features
* PHP 5.5 including the following additional extensions
  * php5-mysql
  * php5-sqlite
  * php5-curl
  * php5-intl
  * php5-xdebug
* Apache 2.4 including
  * mod_rewrite
* Config for DEV and PROD (*not recommended*) usage
  * DEV
    * xdebug configured with remote_connect_back
  * PROD
    * opcache with recommended settings for performance
    * xdebug extension disabled by default

## Running your ZF2 application in Docker

Run your docker container and adjust `/home/user/git/your-zf2-app`
to match the local path to your ZF2 Application root.

```bash
cd /home/user/your-zf2-app
sudo docker run -d -p 8080:80 \
        -v $(pwd):/zf2-app maglnet/docker-zf2
```

### Options / environment variables to fine tune the config
```bash
docker run \
    -e DOCKER_ZF2_ENV="DEV" \ # DEV|PROD copies dev or prod config to /etc (default:DEV)
    -e PHP_MODS_DISABLE="xdebug sqlite" # explicitly disable php modules (space separated list of modules)
    -e PHP_MODS_ENABLE="mysql opcache" # explicitly enable php modules (space separated list of modules)

```

## Examples

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
Configure your application to use MySQL User `root` and get the password
from the linked MySQL container by `getenv('MYSQL_ENV_MYSQL_ROOT_PASSWORD')`

Since IP-Addresses are provided dynamically, you need to get the MySQL containers
IP-Address through `getenv('MYSQL_PORT_3306_TCP_ADDR')`:

```php
return array(
    'db' => array(
        [...]
        'dsn'            => 'mysql:dbname=zf2-tutorial;host=' . getenv('MYSQL_PORT_3306_TCP_ADDR'),
        'password'       => getenv('MYSQL_ENV_MYSQL_ROOT_PASSWORD'),
        [...]
);
```

## Contributing
Feel free to open issues or fork and create a PR.


## License
docker-zf2 is licensed under the MIT license.
See the included LICENSE file.
