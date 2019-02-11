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
Crea_Virtualhost
