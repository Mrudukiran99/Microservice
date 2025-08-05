# Use official Node.js LTS version as the base image
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy dependency definition files
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of your app's source code (including index.js)
COPY . .

# Expose the port your app listens on
EXPOSE 3000

# Start your app
CMD ["node", "index.js"]
