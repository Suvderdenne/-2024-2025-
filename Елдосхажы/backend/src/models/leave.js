'use strict'

const {model, Schema} = require("mongoose");

const Leave = model(
    "Leave",
    new Schema({
        id: String,
        userId: String,
        start: Date,
        end: Date,
        type: {
            type: String,
            default: "fullday"
        },
        title: String,
        description: String,
        status: String,
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Leave;