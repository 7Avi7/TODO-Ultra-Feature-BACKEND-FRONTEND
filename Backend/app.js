const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");

const userRouter = require("./routers/userRouter");
const todoRouter = require("./routers/todoRouter");
const publicRouter = require("./routers/publicRouter");

const emailRouter = require("./routers/emailRouter");
const authorRouter = require("./routers/authorRouter");

const app = express();

app.use(express.static("public"));
app.use("/uploads", express.static("uploads"));

// Parse JSON bodies
app.use(bodyParser.json());

// Use routers
app.use("/", userRouter);
app.use("/", todoRouter);
app.use("/", publicRouter);

app.use("/", emailRouter);

// Use the authorRouter for requests starting with /authors
app.use("/avi", authorRouter);

module.exports = app;
