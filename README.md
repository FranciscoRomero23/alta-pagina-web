# alta-pagina-web
Script bash que permite habilitar una nueva página web y su acceso por ftp.
## Funcionamiento
El script realiza tres tareas:
1. Crea un virtualhost nuevo para la nueva página web.
2. Crea los directorios para la página web.
3. Habilita la página web en el servidor dns.

El script funciona utilizando una clave ssh con la que se conecta a los servidores y realiza las tareas.
