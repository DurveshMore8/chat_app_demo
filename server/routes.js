import express from "express";
import { Message, User } from "./schema.js";

const router = express.Router();

router.post("/signin", async (req, res) => {
  try {
    const { name, email } = req.body;

    const existUser = await User.findOne({ email });

    if (!existUser) {
      const user = new User({ name, email });
      await user.save();
    }

    res.json({ message: "done" });
  } catch (e) {
    console.log(e);
  }
});

router.get("/users", async (req, res) => {
  try {
    const users = await User.find({});

    res.json({ users });
  } catch (e) {
    console.log(e);
  }
});

router.post("/get-chats", async (req, res) => {
  const { senderEmail, recipientEmail } = req.body;

  try {
    const messages = await Message.find({
      $or: [
        { senderEmail: senderEmail, recipientEmail: recipientEmail },
        { senderEmail: recipientEmail, recipientEmail: senderEmail },
      ],
    }).sort({ timestamp: 1 });

    res.json({ messages });
  } catch (e) {
    console.log(e);
  }
});

export default router;
