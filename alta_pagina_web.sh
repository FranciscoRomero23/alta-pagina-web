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
Crea_Virtualhost
Crea_Directorio
