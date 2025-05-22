'use strict'

const {model, Schema} = require("mongoose");

const Notification = model(
    "Notification",
    new Schema({
        id: String,
        userId: String,
        projectId: String,
        taskId: String,
            title: String,
        description: String,
        roles: Array, // Admin, Manager
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Notification;