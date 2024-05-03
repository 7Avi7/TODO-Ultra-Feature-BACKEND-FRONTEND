const router = require("express").Router();

const TodoController = require("../controller/todoController");

router.post("/storeTodo", TodoController.createTodo);

// This Route is For Testing on Postman
router.get("/getUserTodoList", TodoController.getUserTodo);

// This Route is For Flutter Project
router.post("/getUserTodoList", TodoController.getUserTodo);

router.post("/deleteTodo", TodoController.deleteTodo);

module.exports = router;
