'use strict'

const {model, Schema} = require("mongoose");

const Task = model(
    "Task",
    new Schema({
        id: String,
            userId: String, // Assigned
            projectId: String,
        title: { type: String, text: true },
        description: String,
        dueDate: String,
        status: Boolean,
        progress: Number, // In percentage
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Task;