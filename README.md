## Descripción

Maquina virtual (VM) de Vagrant optimizada para desarrollo de sitios web. Se configuro pensando en los paquetes esenciales para no sobrecargar la maquina, eso quiere decir que con algunas modificaciones menores (ver "Para producción") puede utilizarse también en producción.

Al inicializar la VM, además de las tareas propias de instalación de paquetes y configuración, también se configura un dominio y una base de datos en blanco. El nombre de ambos puede ser modificado al inicio del archivo install.sh

```
#!/bin/bash

domain_name="labs.con"
PASSWORD='root'
db_name="labs_db"
```

La VM cuenta con

* Debian “Jessie” 8 x64
* Apache 2.4
* MySQL 5.5
* PHP 5 FPM
  * Incluyendo módulos útiles como curl, gd, pear, imagick, mcrypt y memcached
* Git
* Composer
* WP CLI 

En la mayoría de paquetes utilizará la última versión estable disponible en Aptitude.

### Para producción

Las consideraciones que se deben tener si se quiere utilizar en producción son principalmente de seguridad y optimización. En seguridad se debe revisar la contraseña SSH y de la base de datos. También se debe revisar los permisos de la BD en cuanto las direcciones desde las que permite conexión, por defecto se configuró para que acepte conexiones de cualquier IP.

En optimización haría falta instalar y configurar APC .También configuraciones de cache y compresión gzip.

### Requerimientos

* Vagrant 1.7+ instalado. Si no, descargar Vagrant.
* Git instalado. Si no, puede descargar el repo manualmente de lamp-essential.

## Descargar los archivos de la VM e instalar los plugins requeridos de Vagrant

```
clone https://github.com/ivanmendoza/lamp-essential.git
cd lamp-essential
chmod +x *.sh
./setup-vagrant.sh
```

## Iniciar VM

Antes de correr el comando para levantar la VM de Vagrant se puede/debe configurar los detalles del script install.sh que configura el dominio a utilizar. También en ese mismo archivo se puede personalizar qué paquetes se quieren instalar.

```
vagrant up
# Esperar. 
# Si es primera vez que se ejecuta, dependiendo la velocidad de conexión a Internet puede durar entre 8 y 15 minutos. 
# Si no es primera vez pero se levantará desde cero tardará alrededor de 8 minutos (porque el SO ya estará cacheado localmente)
# Si solo se esta "despertando" la VM entonces tarda menos de un min.
```

## Conectarse a la VM

### Web

* http://127.0.0.1:8080
* http://labs.con:8080 (o el dominio que se haya configurado)

### MySQL

* servidor: 127.0.0.1
* usuario: root
* contraseña: root
* puerto: 3380

### SSH

en la carpeta de la VM correr el siguiente comando

```
vagrant ssh
```

o si se quiere conectar por el comando tradicional de SSH usar los siguietes datos de acceso

* servidor: 127.0.0.1:2222
* usuario: vagrant
* contraseña: vagrant

## Issues conocidos

* Por alguna razón desconocida aunque se configure una contraseña personalizada para MySQL, seguirá usando la contraseña "root" al conectarse remotamente. Sin embargo, localmente y para fines de conexión de aplicaciones web la contraseña si es la que se le indique en la variable PASSWORD (ver install.sh). Al parecer el problema se encuentra en la tabla de permisos en donde el usuario "root" puede manejar diferentes contraseñas según la IP desde se conecta.
  * Haría falta entonces agregar al script un comando que se aseguré de cambiar TODAS las contraseñas del usuario root.
* En algunos casos cuando se cambia la configuración y se vuelve a iniciar la VM (usando vagrant reload o vagrant up) puede que Apache se detenga, dejando el servidor web inactivo. Esto ocurre con frecuencia cuando se cambian los archivos de provisionamiento y se corren múltiples veces. La forma de solucionarlo es iniciar el servicio de Apache

```
# desde la carpeta de la VM correr el comando
vagrant ssh
# esperar a que se conecte
sudo service apache2 start
# listo, ahora puedes desconectarte
exit
```

