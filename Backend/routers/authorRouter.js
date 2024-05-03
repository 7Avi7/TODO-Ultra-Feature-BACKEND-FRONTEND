const express = require("express");
const fs = require("fs");

const router = express.Router();

// Define route to fetch author data
router.get("/author", (req, res) => {
  // Read the content of author.json file
  fs.readFile("./author.json", "utf8", (err, data) => {
    if (err) {
      console.error("Error reading author.json file:", err);
      return res.status(500).json({ error: "Internal server error" });
    }

    try {
      const authorData = JSON.parse(data);
      res.json(authorData);
    } catch (parseError) {
      console.error("Error parsing author.json file:", parseError);
      res.status(500).json({ error: "Internal server error" });
    }
  });
});

module.exports = router;
