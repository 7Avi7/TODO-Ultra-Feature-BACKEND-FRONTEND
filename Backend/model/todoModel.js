const mongoose = require("mongoose");
const db = require("../config/db");
const UserModel = require("../model/userModel");
const { Schema } = mongoose;

const todoSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: UserModel.modelName,
  },

  title: {
    type: String,
    required: true,
  },
  desc: {
    type: String,
    required: true,
  },
});

const ToDoModel = mongoose.model("todo", todoSchema);

module.exports = ToDoModel;
