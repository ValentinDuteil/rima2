FROM node:20-alpine

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./
RUN pnpm config set approve-builds true
RUN pnpm install --ignore-scripts=false

COPY . .

EXPOSE 3000

CMD ["pnpm", "run", "dev"]