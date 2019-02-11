#!/bin/bash

# Script bash que permite habilitar una nueva página web y su acceso por ftp.
# Francisco José Romero Morillo, 2019

## Parametros
# Clave ssh
clavessh="/home/francisco/.ssh/clave_openstack"
# Servidores
servidorweb="172.22.200.57"
servidordns=""

nombre_pagina=$1

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
	ssh -i $clavessh root@$servidorweb echo "$nombre_usuario10" | passwd $nombre_usuario --stdin
	# Añadimos el usuario al servidor ftp
	ssh -i $clavessh root@$servidorweb echo "DefaultRoot     /var/www/$nombre_pagina/public_html  $nombre_usuario" >> /etc/proftpd.conf
	# Reiniciamos el servidor ftp
        ssh -i $clavessh root@$servidorweb systemctl restart proftpd
}
Crea_Virtualhost
Crea_Directorio
Crea_UsuarioFtp
