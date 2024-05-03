const express = require("express");
const router = express.Router();
const UserController = require("../controller/userController");
const upload = require("../config/multerConfig"); // Import multer middleware

// SIGN UP with photo upload
router.post("/registration", upload.single("photo"), UserController.register);

// LOG IN
router.post("/login", UserController.login);

// Route for getting user information
router.get("/user/:userId", UserController.getUserInfo);

// Route for serving uploaded photos
router.use("/photos", express.static("public/uploads"));

// Update user profile
router.put("/user/:userId", UserController.updateUserProfile);

module.exports = router;
