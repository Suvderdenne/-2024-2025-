'use strict'

const {model, Schema} = require("mongoose");

const Setting = model(
    "Setting",
    new Schema({
            id: String,
        name: String,
        address: String,
        city: String,
        country: String,
        email: String,
        phone: String,
        leaveLimit: Number
    }, { timestamps: true })
);

module.exports = Setting;