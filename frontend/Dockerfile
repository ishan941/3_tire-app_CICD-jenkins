FROM node:18.19.1
WORKDIR /app    
COPY package.json .
RUN npm i
# this copies complete source code
COPY . . 
EXPOSE 5173
CMD ["npm","run","dev"]