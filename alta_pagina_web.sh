#!/bin/bash

# Script bash que permite habilitar una nueva página web y su acceso por ftp.
# Francisco José Romero Morillo, 2019

## Parametros
# Clave ssh
clavessh="/home/francisco/.ssh/clave_openstack"
# Servidores
servidorweb="172.22.200.57"
servidordns="172.22.200.60"
# Zonas del servidor dns
zonadirecta="/var/cache/bind/db.francisco.gonzalonazareno.org"
# Página y usuario
nombre_pagina=$1
nombre_usuario=$2

# Funciones

function Crea_Virtualhost {
        # Creamos el virtualhost
        scp -i $clavessh ./default-host.conf root@$servidorweb:/etc/httpd/sites-available/$nombre_pagina.conf
        ssh -i $clavessh root@$servidorweb sed -i s/'paginaweb'/$nombre_pagina/g /etc/httpd/sites-available/$nombre_pagina.conf
        # Habilitamos el virtualhost
        ssh -i $clavessh root@$servidorweb ln -s /etc/httpd/sites-available/$nombre_pagina.conf /etc/httpd/sites-enabled/$nombre_pagina.conf
}
function Crea_Directorio {
        # Creamos el directorio
        ssh -i $clavessh root@$servidorweb mkdir -p /var/www/$nombre_pagina/public_html
        # Creamos un index.html de ejemplo
        ssh -i $clavessh root@$servidorweb touch /var/www/$nombre_pagina/public_html/index.html
        scp -i $clavessh ./default-index.html root@$servidorweb:/var/www/$nombre_pagina/public_html/index.html
        ssh -i $clavessh root@$servidorweb sed -i s/'paginaweb'/$nombre_pagina/g /var/www/$nombre_pagina/public_html/index.html
        # Reiniciamos el servidor web
        ssh -i $clavessh root@$servidorweb systemctl restart httpd
}
function Crea_UsuarioFtp {
        # Creamos el usuario para el servidor ftp
        ssh -i $clavessh root@$servidorweb useradd -m $nombre_usuario
        # Creamos la contraseña del usuario
        password=""$nombre_usuario"$(($RANDOM%9999))"
        ssh -i $clavessh root@$servidorweb 'echo '$nombre_usuario':'$password' | chpasswd'
        # Añadimos el usuario al servidor ftp
        ssh -i $clavessh root@$servidorweb 'echo "DefaultRoot     /var/www/"'$nombre_pagina'"/public_html  "'$nombre_usuario'"" >> /etc/proftpd.conf'
        # Reiniciamos el servidor ftp
        ssh -i $clavessh root@$servidorweb systemctl restart proftpd
}
function Habilita_Pagina {
	# Añadimos el nuevo registro cname
	nuevocname=""$nombre_pagina"	IN	CNAME	zapatero"
	ssh -i $clavessh root@$servidordns 'echo '$nuevocname' >> '$zonadirecta''
	# Reiniciamos el servidor dns
	ssh -i $clavessh root@$servidordns systemctl restart bind9
	ssh -i $clavessh root@$servidordns rndc reload
}

# Ejecutamos las funciones
Crea_Virtualhost
Crea_Directorio
Crea_UsuarioFtp
Habilita_Pagina
