const express = require("express");
const router = express.Router();
const path = require("path");
const fs = require("fs");

// Route for serving photos from the public directory
router.get("/:photoName", (req, res) => {
  const photoName = req.params.photoName;
  const imagePath = path.join(__dirname, `../public/${photoName}`);

  // Check if the file exists
  if (fs.existsSync(imagePath)) {
    // Send the file as a response
    res.sendFile(imagePath);
  } else {
    // If the file doesn't exist, return a 404 error
    res.status(404).send("File not found");
  }
});

module.exports = router;
