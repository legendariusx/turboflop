FROM oven/bun
WORKDIR /turboflop-web
COPY . .
RUN bun i
RUN bun x vite build
RUN bun i -g serve
EXPOSE 8080
CMD ["bun", "x", "serve", "-s", "dist", "-l", "8080"]