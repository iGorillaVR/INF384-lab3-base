# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# Etapa 1: Construccion
FROM public.ecr.aws/lambda/nodejs:22 AS build

WORKDIR /app

# Copiar manifiesto y lock file antes del codigo
COPY package.json package-lock.json ./

# Instalar dependencias desde el lock file
RUN npm ci

# Copiar codigo fuente
COPY src/ ./src/

# Construir el artefacto empaquetado
RUN npm run build

# Etapa 2: Imagen final de Lambda
FROM public.ecr.aws/lambda/nodejs:22

# Copiar solamente el artefacto construido
COPY --from=build /app/dist/handler.js ${LAMBDA_TASK_ROOT}/dist/handler.js

# Ejecutar el handler empaquetado
CMD ["dist/handler.handler"]
