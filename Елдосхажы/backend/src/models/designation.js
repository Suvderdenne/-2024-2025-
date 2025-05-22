'use strict'

const {model, Schema} = require("mongoose");

const Designation = model(
    "Designation",
    new Schema({
        id: String,
        departmentId: String,
        name: {
            type: String,
            text: true
        },
        description: String,
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Designation;