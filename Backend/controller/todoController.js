const ToDoServices = require("../services/todoServices");

exports.createTodo = async (req, res, next) => {
  try {
    const { userId, title, desc } = req.body;

    let todo = await ToDoServices.createToDo(userId, title, desc);

    res.json({ status: true, success: todo });
  } catch (error) {
    next(error);
  }
};

exports.getUserTodo = async (req, res, next) => {
  try {
    const { userId } = req.body;

    let todo = await ToDoServices.getTodoData(userId);

    res.json({ status: true, success: todo });
  } catch (error) {
    next(error);
  }
};

exports.deleteTodo = async (req, res, next) => {
  try {
    const { id } = req.body;

    let deleted = await ToDoServices.deleteTodo(id);

    res.json({ status: true, success: deleted });
  } catch (error) {
    next(error);
  }
};
