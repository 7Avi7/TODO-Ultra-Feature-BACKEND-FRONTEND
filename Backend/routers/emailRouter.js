const nodemailer = require("nodemailer");
const express = require("express");
const router = express.Router();

router.post("/email", function (req, res) {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "avilashbhowmik7@gmail.com",
      pass: "vzaupmglgxzapzyz",
    },
  });

  async function main() {
    const info = await transporter.sendMail({
      to: "avilashbhowmik7@gmail.com",
      subject: req.body.subject,
      text: req.body.text,
    });

    console.log("Message sent: %s", info.messageId);
  }

  res.send("sent your message");
  main().catch(console.error);
});

module.exports = router;
