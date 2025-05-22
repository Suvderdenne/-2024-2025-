'use strict'

const {model, Schema} = require("mongoose");

const Project = model(
    "Project",
    new Schema({
        id: String,
        name: {type: String, text: true},
        description: String,
        status: Boolean,
        progress: Number, // In percentage
        completedAt: Date,
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Project;