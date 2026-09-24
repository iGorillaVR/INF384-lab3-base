
# Etapa 1: construcción
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

# Instalar dependencias desde el lock file
COPY package.json package-lock.json ./
RUN npm ci

# Copiar el código fuente y generar el artefacto
COPY src/ ./src/

RUN npx esbuild src/handler.js \
    --bundle --platform=node --target=node20 \
    --outfile=dist/handler.js

# Etapa 2: imagen final de Lambda
FROM public.ecr.aws/lambda/nodejs:20 AS runtime

# Copiar únicamente el artefacto construido
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/

CMD ["handler.handler"]
