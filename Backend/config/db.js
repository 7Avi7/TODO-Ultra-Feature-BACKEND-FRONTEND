const mongoose = require("mongoose");

const connection = mongoose
  .connect("mongodb://localhost:27017/ToDo")
  .then(() => console.log("database connection successful!"))
  .catch((err) => console.log(err));

module.exports = connection;
