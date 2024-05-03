const jwt = require("jsonwebtoken");
const UserService = require("../services/userServices");

const secretKey = "osduhvlisbdvkjsdbvlkjsdvliusdfwhefcoih";

// CREATE A USER
exports.register = async (req, res, next) => {
  try {
    const { email, password, name, mobile, address } = req.body;
    const photoPath = req.file ? req.file.filename : null; // Use filename instead of full path

    const successRes = await UserService.registerUser(
      email,
      password,
      name,
      mobile,
      address,
      photoPath
    );

    res.status(200).json({
      message: "User registered successfully",
      data: { ...successRes.toObject(), photo: photoPath }, // Return photo path in response
    });
  } catch (error) {
    next(error);
  }
};

// USER LOGIN
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await UserService.checkUser(email);

    if (!user) {
      throw new Error("User doesn't exist");
    }

    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      throw new Error("Invalid Password");
    }

    const tokenData = { _id: user._id, email: user.email };
    const token = jwt.sign(tokenData, secretKey, {
      expiresIn: "7d",
      algorithm: "HS256",
    });

    res.status(200).json({ status: true, token: token });
  } catch (error) {
    next(error);
  }
};

exports.getUserInfo = async (req, res, next) => {
  try {
    const userId = req.params.userId; // <-- Extracting userId from params
    const userInfo = await UserService.getUserInfo(userId); // <-- Passing userId to service

    res.status(200).json({
      message: "User information retrieved successfully",
      data: userInfo,
    });
  } catch (error) {
    next(error);
  }
};

// Update user profile
exports.updateUserProfile = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const { name, mobile, address } = req.body;
    const photoPath = req.file ? req.file.filename : null;

    // Construct the update object with only the fields to be updated
    const updateData = {};
    if (name) updateData.name = name;
    if (mobile) updateData.mobile = mobile;
    if (address) updateData.address = address;
    if (photoPath) updateData.photo = photoPath;

    // Update user information
    await UserService.updateUserProfile(userId, updateData);

    res.status(200).json({
      message: "User profile updated successfully",
    });
  } catch (error) {
    next(error);
  }
};
