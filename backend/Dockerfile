FROM node:18.19.1
WORKDIR /app    
COPY package.json .
RUN npm i
COPY . .
EXPOSE 5050
CMD ["npm","start"]