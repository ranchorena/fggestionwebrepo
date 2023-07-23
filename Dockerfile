# Partimos de una imagen base de nginx
FROM nginx

# Copiamos el archivo de configuración nginx.conf al contenedor
COPY nginx.conf /etc/nginx/nginx.conf

# Copiamos la aplicación web Angular desde la carpeta ./dist al directorio de trabajo del contenedor (/usr/share/nginx/html)
COPY /dist /usr/share/nginx/html

# Exponemos el puerto 82 para acceder a la aplicación web desde afuera del contenedor
EXPOSE 82
EXPOSE 80/tcp

# Eliminar cualquier archivo o enlace simbólico existente en el directorio /var/log/nginx
RUN rm -f /var/log/nginx/access.log && \
    rm -f /var/log/nginx/error.log && \
    rm -f /var/log/nginx/access.log.1 && \
    rm -f /var/log/nginx/error.log.1

# Creamos un directorio para almacenar los logs
# RUN mkdir /var/log/nginx

# Configuramos nginx para que genere un log de acceso
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Levantamos el servidor nginx
CMD ["nginx", "-g", "daemon off;"]