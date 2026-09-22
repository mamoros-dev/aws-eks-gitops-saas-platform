# 1. Image base: Official lightweight Python image (Linux Alpine/Slim)
# 1. Imagen base ligera oficial de Python (Linux Alpine/Slim)
FROM python:3.11-slim

# 2. Set the working directory inside the container
# 2. Definimos el directorio de trabajo dentro del contenedor
WORKDIR /app

# 3. Copy requirements file
# 3. Copiamos el archivo de dependencias
COPY requirements.txt .

# 4. Install the libraries without caching to keep the image small.
# 4. Instalamos las librerías sin guardar caché para mantener la imagen pequeña
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy our application's source code.
# 5. Copiamos el código fuente de nuestra aplicación
COPY app/ ./app/

# 6. Expose port 80 inside the container.
# 6. Exponemos el puerto 80 dentro del contenedor
EXPOSE 80

# 7. Command to start the Python web server (uvicorn) on port 80
# 7. Comando para arrancar el servidor web de Python (uvicorn) en el puerto 80
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
