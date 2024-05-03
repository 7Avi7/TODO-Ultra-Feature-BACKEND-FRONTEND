const UserModel = require("../model/userModel");
const jwt = require("jsonwebtoken");

// POST Users (Create)
const registerUser = async (
  email,
  password,
  name,
  mobile,
  address,
  photoPath
) => {
  try {
    const createUser = new UserModel({
      email,
      password,
      name,
      mobile,
      address,
      photo: photoPath,
    });
    return await createUser.save();
  } catch (error) {
    throw error;
  }
};

// Static method to check if user exists
const checkUser = async (email) => {
  try {
    return await UserModel.findOne({ email }); // Corrected to findOne
  } catch (error) {
    throw error;
  }
};

// GET Users
const getUserInfo = async (userId) => {
  const userInfo = await UserModel.findById(userId).select("-password");

  if (!userInfo) {
    throw new Error("User not found");
  }

  return userInfo;
};

// Update user profile
const updateUserProfile = async (userId, newData) => {
  try {
    // Find the user by ID and update the specified fields
    await UserModel.findByIdAndUpdate(userId, newData);

    // If a new photo is uploaded and the previous photo exists, remove the previous photo
    if (newData.photo) {
      const user = await UserModel.findById(userId);
      if (user.photo) {
        const photoPath = `public/uploads/${user.photo}`;
        // Check if the file exists before attempting to remove it
        if (fs.existsSync(photoPath)) {
          fs.unlinkSync(photoPath);
        }
      }
    }
  } catch (error) {
    throw error;
  }
};

module.exports = {
  registerUser,
  checkUser,
  getUserInfo,
  updateUserProfile,
};
