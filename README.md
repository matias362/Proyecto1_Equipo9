Proyecto Integrador Final (PIN) – Devops 2502 

Proyecto 1: CI/CD con GitHub Actions + Terraform + Docker

📌 Descripción

Este proyecto implementa un pipeline completo que incluye:

- Integración continua con GitHub Actions
- Chequeo de salud nativo usando libreria Supertest
- Análisis de código estático con Eslint
- Análisis de vulnerabilidades con Snyk
- Generación de SBOM con Trivy (CycloneDX)
- Build y publicación de imagen Docker en Amazon ECR
- Despliegue automatizado con Terraform
- Observabilidad con Prometheus + Blackbox Exporter + Grafana

El objetivo es demostrar un flujo automatizado y seguro desde el commit hasta la ejecución productiva en AWS.

🏗 Arquitectura

Flujo general

1) Workflow de Github se activa cuando se realiza un push sobre la rama main

2) GitHub Actions ejecuta:
 
    - Chequeo nátivo de salud con Supertest (sin servidor)
    - Eslint para chequeo de código estático
    - Snyk para análisis de vulnerabilidades
    - Build de imagen Docker con Dockerfile
    - SBOM con Trivy
    - Push de imagen a Amazon ECR

3) Terraform despliega infraestructura en AWS

4) EC2 realiza pull de la imagen y levanta:
    
    - Aplicación Nodejs (Puerto 3000)
    - Prometheus (Puerto 9090)
    - Blackbox Exporter (Puerto 9115)
    - Grafana (Puerto 3001)
    - Aplicación Nodejs

🔎 Descripción de Componentes

- Aplicación
    - server.js → Servidor principal de la aplicación.
    - app.test.js → Pruebas con Supertest.
    - package.json / package-lock.json → Gestión de dependencias.
    - .eslintrc.js → Configuración de ESLint.

- Comportamiento y Exposición de la API
    - Se ejecuta sobre el puerto 3000
    - Expone un endpoint de verificación de estado (health check)
    - Implementa endpoints REST para operaciones básicas:
       - GET /health -> Verificación de estado del servicio (usado por monitoreo)
       - GET /api/productos -> Obtiene el listado de productos
       - POST /api/carrito -> Agrega productos al carrito

⚙️ Configuración Inicial (pasos manuales)

Antes de ejecutar el pipeline se realizaron las siguientes configuraciones manuales:

- 🔐 Seguridad y accesos
    - Integración de Snyk con GitHub mediante Token
    - Creación de repositorio privado en Amazon ECR
    - Creación de usuario IAM para CI/CD:
        - Permisos mínimos para push a ECR
    - Creación de usuario IAM para Terraform:
        - Permisos mínimos para creación de infraestructura
    - Creación de Key Pair para acceso SSH a EC2

🚀 CI/CD – GitHub Actions

🔁 Flujo del Pipeline

GitHub Actions ejecuta las siguientes etapas en orden:

1️⃣ Validación Funcional – Supertest

Se ejecutan pruebas de integración utilizando Supertest, permitiendo validar el endpoint /health sin necesidad de levantar el servidor completo.

- Objetivo:
    - Verificar que la aplicación responde correctamente
    - Detectar errores funcionales antes del build
    - Esto garantiza que la imagen solo se construya si la aplicación funciona correctamente.

2️⃣ Análisis Estático de Código – ESLint

- Se ejecuta ESLint para analizar el código fuente y detectar:
   - Errores de sintaxis
   - Malas prácticas
   - Problemas de estilo
   - Potenciales bugs
   - El pipeline se detiene si se detectan errores críticos.

3️⃣ Análisis de Vulnerabilidades – Snyk

- Se realiza un escaneo de dependencias mediante Snyk:
   - Identificación de vulnerabilidades conocidas (CVE)
   - Bloqueo del pipeline ante vulnerabilidades sin remediación
   - Revisión del package-lock.json
   - Esto garantiza seguridad en las dependencias del proyecto.

4️⃣ Build de Imagen Docker

Si las etapas anteriores son exitosas, se construye la imagen Docker utilizando el Dockerfile del proyecto:

    docker build --provenance false -t proyecto1_grupo9:latest .

Esta imagen constituye el artefacto principal de despliegue.

5️⃣ Generación de SBOM – Trivy
    
Se genera un Software Bill of Materials (SBOM) utilizando Trivy en formato CycloneDX.

Esto permite:
   - Inventariar dependencias incluidas en la imagen
   - Facilitar auditorías de seguridad
   - Mejorar trazabilidad del software
   - El SBOM se almacena como artefacto del workflow.

6️⃣ Publicación en Amazon ECR

Finalmente, la imagen es:
    
Etiquetada con el URI del repositorio ECR

    docker tag proyecto1_grupo9:latest 076194732070.dkr.ecr.us-east-1.amazonaws.com/mundose/proyecto1_equipo9:latest

Publicada en el repositorio privado de Amazon ECR

    docker push 076194732070.dkr.ecr.us-east-1.amazonaws.com/mundose/proyecto1_equipo9:latest

Esta imagen será posteriormente utilizada por Terraform durante el despliegue en EC2.

🐳 Artefacto Docker

Además del push a ECR, la imagen fue exportada mediante:

    docker save -o proyecto1_grupo9.tar 076194732070.dkr.ecr.us-east-1.amazonaws.com/mundose/proyecto1_equipo9:latest

Esto permite su distribución offline y evidencia del artefacto generado.


☁️ Despliegue con Terraform

- La infraestructura se despliega utilizando:
    - terraform init
    - terraform plan
    - terraform apply

- Recursos creados:
    - Instancia EC2 con instance profile asociado (permisos para el pull de la imágen)
    - Security Groups
    - Configuración de red
    - User-data automatizado

- El user-data realiza:
    - Instalación de Docker
    - Login en ECR
    - Pull de la imagen
    - Ejecución del contenedor
    - Instalación del stack de monitoreo con docker-compose

📊 Observabilidad

- Se implementa monitoreo mediante:
    - Prometheus (recolección de métricas)
    - Blackbox Exporter (monitoreo del endpoint /health)
    - Grafana (visualización)

Prometheus consulta el estado del servicio a través del Blackbox Exporter.
Grafana se conecta a Prometheus como datasource y permite visualizar métricas básicas de disponibilidad.

📂 Estructura del Proyecto (Repositorio Github)

-   La estructura del repositorio es la siguiente:
-   ├── .github/
-   │   └── workflows/
-   │       └── workflow.yml
-   │
-   ├── .eslintrc.js
-   ├── .gitignore
-   ├── Dockerfile
-   ├── README.md
-   │
-   ├── server.js
-   ├── app.test.js
-   ├── package.json
-   ├── package-lock.json
-   │
-   ├── providers.tf
-   ├── variables.tf
-   ├── main.tf
-   ├── network.tf
-   ├── iam.tf
-   ├── data.tf
-   ├── output.tf
-   │
-   └── docs/
-   │   └── imagenes/

🎥 Evidencia en Video

-   Los videos demostrativos incluyen:
    -   Ejecución del workflow en GitHub Actions
    -   Apply con Terraform
    -   Ejecución de la aplicación
    -   Integración Prometheus → Grafana
    -   Visualización del dashboard

Enlace: https://drive.google.com/drive/folders/19OMNcchCODM2bWUxKQmpktJFQGDrZXbH?usp=drive_link

👨‍💻 Autores

Equipo 9 - PIN Devops 2502
    
    Ariel Giri (ariel.giri@nemogroup.net)
    Daniel Raya (daniel.raya@nemogroup.net)
    Marco Ollamburo (marco.ollamburo@nemogroup.net)
    Matías Rocca (matias.rocca@nemogroup.net).
    
