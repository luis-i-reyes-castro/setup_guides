# 2019 Virtual Private Server (VPS) for ProcessMaker

Follow this step-by-step guide to install ProcessMaker on a fresh machine. In this particular example we are using a VPS hosted by Digital Ocean at IPv4 address `XXX.XXX.XXX.XX` which responds to `example-server.tk`. 

### Connect to the server via SSH
```
ssh root@XXX.XXX.XXX.XX
```
**Important:** If you connect to the server using any user other than `root` you will have to prefix `sudo` to almost all of the following commands.

### Configure Timezone
```
dpkg-reconfigure tzdata
```

### Install Apache and MySQL
```
apt-get update
apt-get install apache2 mysql-server
```

### Configure MySQL
First run the MySQL secure installation script.
```
mysql_secure_installation
```
| Prompt | Answer |
| ------ | ------ |
| Would you like to setup VALIDATE PASSWORD plugin? | No |
| Please select a password for root. | `[password]` |
| Remove anonymous users? | Yes |
| Disallow root login remotely? | Yes |
| Remove test database and access to it? | Yes |
| Reload privilege tables now? | Yes |

Next use `nano` to open the MySQL configuration file.
```
nano -c /etc/mysql/mysql.conf.d/mysqld.cnf
```
Edit Line 43, under header `[mysqld]`, so that it reads `bind-address = *`.

Finally, declare the VPS hostname to allow for remote root access and restart the MySQL service.
```
mysql -u root -p
```
```SQL
CREATE USER 'root'@'XXX.XXX.XXX.XX' IDENTIFIED BY '[password]';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'XXX.XXX.XXX.XX';
FLUSH PRIVILEGES;
EXIT;
```
```
systemctl restart mysql
```

### Install and configure PHP
First install PHP.
```
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install php7.1 php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-xml php7.1-gd php7.1-ldap php7.1-curl php7.1-cli php7.1-soap php7.1-odbc
```
Then use `nano` to edit PHP's Apache configuration file.
```
nano -c /etc/php/7.1/apache2/php.ini
```
Ensure each of the following lines reads as shown.
* Line 197: `short_open_tag = On`
* Line 404: `memory_limit = 512M`
* Line 460: `error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT`
* Line 671: `post_max_size = 24M`
* Line 815: `file_uploads = On`
* Line 824: `upload_max_filesize = 24M`
* Line 939: `date.timezone = America/Guayaquil`

### Install PhpMyAdmin and grant it access to the database
```
apt-get install phpmyadmin
mysql -u root -p
```
```SQL
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```
```
systemctl restart mysql
```

### Download, install and configure ProcessMaker
First download the software and install it to the `/opt/` directory.
```
wget https://razaoinfo.dl.sourceforge.net/project/processmaker/ProcessMaker/3.3.0/processmaker-3.3.0-community.tar.gz
tar -C /opt/ -xzvf processmaker-3.3.0-community.tar.gz
```

Next use `nano` to create and open ProcessMaker's Apache configuration file.
```
nano /etc/apache2/sites-available/pmos.conf
```
Then paste the following script into the configuration file.
```Apache
# Processmaker Virtual Host (HTTP)
<VirtualHost *:80>

    ServerAdmin luis.i.reyes.castro@gmail.com
    ServerName example-server.tk
    ServerAlias www.example-server.tk

    DocumentRoot /opt/processmaker/workflow/public_html
    DirectoryIndex index.html index.php

    <Directory /opt/processmaker/workflow/public_html>

        Options Indexes FollowSymLinks MultiViews
        AddDefaultCharset UTF-8
        AllowOverride None
        Require all granted
        ExpiresActive On

        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule ^.*/(.*)$ app.php [QSA,L,NC]
        </IfModule>

        #Deflate filter is optional. It reduces download size, but adds slightly more CPU processing:
        AddOutputFilterByType DEFLATE text/html

    </Directory>

</VirtualHost>
```

Finally setup permissions.
```
chown -R www-data:www-data /opt/processmaker/
```

### Fix timezone issue
Use `nano` to edit configuration file `/opt/processmaker/config/app.php`. 
```
nano /opt/processmaker/config/app.php
```

Add the command `'timezone' => 'America/Guayaquil',` at Line 15 so that the resulting file looks as shown below.
```PHP
<?php

use Illuminate\Cache\CacheServiceProvider;
use Illuminate\Filesystem\FilesystemServiceProvider;
use Illuminate\View\ViewServiceProvider;

return [
    'name' => env('APP_NAME', 'ProcessMaker'),
    'url' => env('APP_URL', 'http://localhost'),
    'env' => env('APP_ENV', 'production'),
    'debug' => env('APP_DEBUG', false),
    'log' => env('APP_LOG', 'single'),
    'log_level' => env('APP_LOG_LEVEL', 'debug'),
    'cache_lifetime' => env('APP_CACHE_LIFETIME', 60),
    'timezone' => 'America/Guayaquil',

    'providers' => [
        FilesystemServiceProvider::class,
        CacheServiceProvider::class,
        ViewServiceProvider::class,
        Illuminate\Database\DatabaseServiceProvider::class,
        Illuminate\Foundation\Providers\ConsoleSupportServiceProvider::class,
        Illuminate\Queue\QueueServiceProvider::class,
        Illuminate\Translation\TranslationServiceProvider::class,

    ],

    'aliases' => [
    ],

];
```

### Enable Apache2 site for ProcessMaker
First we create a symbolic link pointing to the PhpMyAdmin's Apache configuration file and place it in the server's sites available directory.
```
ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
```

Then we enable several modules, enable the PhpMyAdmin configuration, disable the default site, and enable the ProcessMaker site.
```
a2enmod ldap authnz_ldap deflate expires rewrite ssl vhost_alias filter
a2enconf phpmyadmin
a2dissite 000-default.conf
a2ensite pmos.conf
systemctl restart apache2
```

### Launch ProcessMaker and setup the administrator account
Copy the server's IP address into a browser to initialize the ProcessMaker server.

| Option | Answer |
| ------ | ------ |
| Workspace Name | workspace |
| Admin Username | admin |
| Admin Password | `[password]` |
| Workflow Database Name | db_workspace |
| Delete dataset if it exists? | Yes |
| The mysql user from the previous step will be the database owner? | Yes |

### Setup domain name and DNS
Go to `freenom.com` and obtain the free domain `example-server.tk`. Click on the *Manage Domain* button and then on the *Manage Freenom DNS* tab. Then add or edit records so that the final records table looks as shown below.

| Name | Type  | TTL   | Target |
| ---- | ----- | ----- | ------ |
|      | A     | 14440 | XXX.XXX.XXX.XX |
| WWW  | CNAME | 14440 | example-server.tk |

### Configure and enable firewall
```
ufw allow 'OpenSSH'
ufw allow 'Apache Full'
ufw enable
ufw status
reboot
```

### Install and run LetsEncrypt's Certbot
First download and install the software
```
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install python-certbot-apache
```

Then run the Certbot, selecting option 2 (Redirect) when asked whether or not to redirect HTTP traffic to HTTPS.
```
certbot --apache -d example-server.tk -d www.example-server.tk
```

### Redirect HTTP traffic to HTTPS
Use `nano` to edit ProcessMaker's Apache configuration file. Go to line 30 and insert the command `RewriteEngine On` before the lines that begin with `RewriteCond %{SERVER_NAME}`. The final configuration file should look as shown below.
```Apache
# Processmaker Virtual Host (HTTP)
<VirtualHost *:80>

    ServerAdmin luis.i.reyes.castro@gmail.com
    ServerName example-server.tk
    ServerAlias www.example-server.tk

    DocumentRoot /opt/processmaker/workflow/public_html
    DirectoryIndex index.html index.php

    <Directory /opt/processmaker/workflow/public_html>

        Options Indexes FollowSymLinks MultiViews
        AddDefaultCharset UTF-8
        AllowOverride None
        Require all granted
        ExpiresActive On

        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule ^.*/(.*)$ app.php [QSA,L,NC]
        </IfModule>

        #Deflate filter is optional. It reduces download size, but adds slightly more CPU processing:
        AddOutputFilterByType DEFLATE text/html

    </Directory>

RewriteEngine On
RewriteCond %{SERVER_NAME} =example-server.tk [OR]
RewriteCond %{SERVER_NAME} =www.example-server.tk
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

</VirtualHost>
```
Finally restart the Apache server.
```
systemctl restart apache2
```
