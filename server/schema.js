import { Schema, model } from "mongoose";

const userSchema = new Schema({
  name: String,
  email: String,
});

const User = model("User", userSchema);

const messageSchema = new Schema({
  senderName: String,
  senderEmail: String,
  recipient: String,
  recipientEmail: String,
  content: String,
  timestamp: { type: Date, default: Date.now },
});
const Message = model("Message", messageSchema);

export { User, Message };
