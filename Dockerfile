FROM node:22-slim AS builder

# install git to install plugins, and install pnpm
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN npm install -g pnpm

WORKDIR /usr/src/app
# Copy package files
COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml* .npmrc* ./
COPY quartz/ ./quartz/
COPY quartz.lock.json* .

# Install dependencies and plugins
RUN pnpm install --frozen-lockfile && pnpm exec quartz plugin install

FROM node:22-slim

# Install pnpm in runtime image
RUN npm install -g pnpm

WORKDIR /usr/src/app

# Copy node_modules from builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application code
COPY . .

# Expose port
EXPOSE 8080

# Start the application
CMD ["pnpm", "run", "quartz", "build", "--serve"]
