# Proyecto1_Equipo9
Repositorio Trabajo Final - Mundos E

Problema encontrado con snyk

Authentication error (SNYK-0005)
401 Unauthorized

Solucion: npx snyk auth (te pide permisos sobre el repo de github. Si das ok, queda como Authorized 0auth apps)

Procesos ejecutados manualmente para probar la app

1) npm install -> genera el package-lock.json
2) npm run test -> testeo nativo de la app
3) npm run lint 
4) npm run snyk-test
5) sudo docker build -t proyecto1_grupo9:latest .
6) sudo docker run -d -p 3000:3000 --name proyecto1_grupo9 proyecto1_grupo9:latest 

----------------------------------------------------------------------------------
01/02/26

Hasta ahora tenemos:

- Workflow completo intentando chequeos con supertest, eslint, snyk
- Buildeo de imagen docker con dockerfile 
- SBOM con trivy y upload al github actions para descarga del informe

Próximos pasos:

- Push de imagen al registry de AWS

----------------------------------------------------------------------------------
15/02/26

Push en la rama main dispara el workflow.yml
    - El ultimo job pushea una imagen a un repositorio de ECR en la cuenta de AWS

Terraform apply sobre el repositorio levantad toda la infraestructura para levantar los siguientes:
    - Aplicación corriendo sobre la EC2
    - Monitoreo corriendo sobre la EC2