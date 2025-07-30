// import express from "express";
// import cors from "cors";
// import records from "./routes/record.js";
// import dotenv from "dotenv";

// dotenv.config();
// const PORT = process.env.PORT;
// const app = express();

// app.use(cors());
// app.use(express.json());
// app.use("/record", records);

// // start the Express server
// app.listen(PORT, () => {
//   console.log(`Server listening on port ${PORT}`);
// });

import express from "express";
import { connectToMongo, getDB } from "./db/connection.js";
import records from "./routes/record.js";
import dotenv from "dotenv";

dotenv.config();
const app = express();
const port = process.env.PORT;

app.use(express.json());
app.use("/record", records);

app.get("/", async (req, res) => {
  try {
    res.json({ message: "Backend API is running", status: "OK" });
  } catch (err) {
    res.status(500).send("Server error");
  }
});

connectToMongo().then(() => {
  app.listen(port, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${port}`);
  });
});
