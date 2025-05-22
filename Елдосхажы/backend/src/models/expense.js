'use strict'

const {model, Schema} = require("mongoose");

const Expense = model(
    "Expense",
    new Schema({
        id: String,
        title: String,
        description: String,
        amount: Number,
        date: Date,
        createdBy: String,
        status: {
            type: String,
            default: "pending"
        },
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Expense;