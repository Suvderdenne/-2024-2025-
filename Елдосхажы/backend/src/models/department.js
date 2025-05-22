'use strict'

const {model, Schema} = require("mongoose");

const Department = model(
    "Department",
    new Schema({
        id: String,
        name: {
            type: String,
            text: true
        },
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Department;