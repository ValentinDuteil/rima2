FROM node:20-alpine

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .

EXPOSE 5173

CMD ["pnpm", "run", "dev", "--host"]

# Note on the "--" before "host": 
# This is necessary to pass the "--host" flag to the underlying Vite development server, 
# allowing it to listen on all network interfaces.