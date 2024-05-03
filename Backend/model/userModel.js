const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const { Schema } = mongoose;

const userSchema = new Schema({
  email: {
    type: String,
    required: true,
    lowercase: true,
    unique: true,
    validate: {
      validator: function (v) {
        // Basic email validation
        return /\S+@\S+\.\S+/.test(v);
      },
      message: (props) => `${props.value} is not a valid email address!`,
    },
  },
  password: {
    type: String,
    required: true,
    validate: {
      validator: function (v) {
        // Strong password validation (minimum 8 characters, at least one capital letter, one special character, and one number)
        return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/.test(
          v
        );
      },
      message: (props) =>
        `${props.value} is not a valid password! It should be at least 8 characters long, containing at least one capital letter, one special character, and one number.`,
    },
  },
  name: {
    type: String,
    required: true,
    minlength: 1, // Minimum length of 1 character
  },
  mobile: {
    type: String,
    required: true,
    validate: {
      validator: function (v) {
        return /\d{11}/.test(v);
      },
      message: (props) =>
        `${props.value} is not a valid mobile number! It should be 11 digits.`,
    },
  },
  address: {
    type: String,
    required: true,
    minlength: 1, // Minimum length of 1 character for address
  },
  photo: {
    type: String,
    required: true, // Photo is required
  },
});

// Hash password before saving
userSchema.pre("save", async function (next) {
  try {
    if (!this.isModified("password")) {
      return next();
    }
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(this.password, salt);
    this.password = hashedPassword;
    next();
  } catch (error) {
    return next(error);
  }
});

// Compare password
userSchema.methods.comparePassword = async function (userPassword) {
  try {
    const isMatch = await bcrypt.compare(userPassword, this.password);
    return isMatch;
  } catch (error) {
    throw error;
  }
};

const userModel = mongoose.model("user", userSchema);

module.exports = userModel;
