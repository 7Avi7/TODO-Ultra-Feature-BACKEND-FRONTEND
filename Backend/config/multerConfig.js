const multer = require("multer");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "public/uploads/"); // Destination folder for file uploads (publicly accessible)
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname); // Rename files to avoid conflicts
  },
});

const upload = multer({ storage: storage });

module.exports = upload;
