# Use official Node.js LTS version as the base image
FROM node:18

# Create app directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your app’s source code
COPY . .

# Expose the port your app listens on (change if needed)
EXPOSE 3000

# Start your app
CMD ["npm", "start"]
