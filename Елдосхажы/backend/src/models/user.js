'use strict'

const {model, Schema} = require("mongoose");

const User = model(
    "User",
    new Schema({
        id: String,
        email: {type: String, text: true},
        password: String,
        name: {type: String, text: true},
        phone: String,
        avatar: {type: String, default: ""},
        country: String,
        city: String,
        address: String,
        gender: String,
        birthday: String,
        description: String,
        // departmentId: String,
        // designationId: String,
        role: String,
        status: Boolean,
        lastActive: Date,
        deletedAt: Date
    }, { timestamps: true })
);


module.exports = User;