'use strict'

const {model, Schema} = require("mongoose");

const Announcement = model(
    "Announcement",
    new Schema({
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        status: Boolean,
        content: String,
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Announcement;