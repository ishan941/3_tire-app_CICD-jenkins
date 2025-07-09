// db.js
import { MongoClient, ServerApiVersion } from "mongodb";
import dotenv from "dotenv";
dotenv.config();

const client = new MongoClient(process.env.MONGO_URI, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
});

let db;

async function connectToMongo() {
  try {
    await client.connect();
    await client.db("admin").command({ ping: 1 });
    console.log("✅ Successfully connected to MongoDB");
    db = client.db("employees");
  } catch (err) {
    console.error("❌ MongoDB connection error:", err);
    process.exit(1); // Stop app if Mongo can't connect
  }
}

function getDB() {
  if (!db) {
    throw new Error("MongoDB not initialized. Did you forget to call connectToMongo()?");
  }
  return db;
}

export { connectToMongo, getDB };
