FROM node:20-alpine

WORKDIR /app    

COPY package.json .

RUN npm i

# this copies complete source code
COPY . . 

EXPOSE 5173

CMD ["npm","run","dev"]