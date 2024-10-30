import express, { json } from "express";
import { connect, Schema, model } from "mongoose";
import { createServer } from "http";
import { Server } from "socket.io";
import cors from "cors";
import { configDotenv } from "dotenv";
import router from "./routes.js";
import { Message } from "./schema.js";
configDotenv();

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

app.use(cors());
app.use(json());
app.use(router);

connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.log(err));

const devices = [];

io.on("connection", (socket) => {
  const socketUser = { id: socket.id, email: socket.handshake.query.email };
  console.log("User  connected: ", socketUser);

  if (devices) {
    const index = devices.findIndex(
      (device) => device.email === socketUser.email
    );

    if (index !== -1) {
      devices[index] = socketUser;
    } else {
      devices.push(socketUser);
    }
  }

  socket.on("send_message", async (data) => {
    const message = new Message(data);
    await message.save();

    const targetUsers = [data.senderEmail, data.recipientEmail];

    const userSocketIds = devices
      .filter((user) => targetUsers.includes(user.email))
      .map((user) => user.id);

    console.log(devices);
    console.log(userSocketIds);

    io.to(userSocketIds).emit("receive_message", message);
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
