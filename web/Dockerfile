FROM oven/bun AS builder
WORKDIR /turboflop
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun x vite build

FROM nginx:alpine
COPY --from=builder /turboflop/dist /usr/share/nginx/html
EXPOSE 80