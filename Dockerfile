FROM node:16

WORKDIR /usr/src/app

# Copy application dependency files
COPY app/package*.json ./

# Install application dependencies
RUN npm install

# Copy application source code
COPY app/ ./

EXPOSE 3000

CMD ["node", "server.js"]
