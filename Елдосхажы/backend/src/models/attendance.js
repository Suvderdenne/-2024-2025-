'use strict'

const {model, Schema} = require("mongoose");
const UserModel = require("../models/user");

const Attendance = model(
    "Attendance",
    new Schema({
        id: String,
        userId: String,
        checkIn: Date,
        ipAddress: { type: String, default: '' },
        checkOut: Date,
        deletedAt: Date
    }, { timestamps: true })
);

module.exports = Attendance;