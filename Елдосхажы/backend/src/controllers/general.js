'use strict'

const SettingModel = require('../models/setting');
const UserModel = require('../models/user');
const {v4: uuidv4} = require("uuid");
const bcrypt = require("bcryptjs");

exports.Initial = async (req, res) => {
    const setting = await SettingModel.findOne({}, {}, {}).lean();
    const user = await UserModel.findOne({role: 'admin'}, {}, {}).lean();

    if (!setting && !user) {
        return res.status(400).send({data: 'Not found'})
    }

    return res.status(200).send({data: 'Found'})
};

exports.Install = async (req, res) => {
    const password = await bcrypt.hash(req.body?.admin?.password, 10);
    const user = new UserModel({
        id: uuidv4(),
        ...req.body.admin,
        password: password,
        role: 'admin',
        status: true,
    });
    await user.save();

    const setting = new SettingModel({
        id: uuidv4(),
        ...req.body.setting
    });
    await setting.save();

    return res.status(200).send({data: 'Success'})
};