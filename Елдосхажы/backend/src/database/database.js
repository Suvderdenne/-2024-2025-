const mongoose = require('mongoose');
const bcrypt = require("bcryptjs");
const UserModel = require("../models/user");
const SettingModel = require("../models/setting");
const {v4: uuidv4} = require("uuid");
const {Role} = require("../constants/constants");

exports.connectDatabase = async () => {
    await mongoose.connect(process.env.MONGODB_URI)
        // .then(async () => {
        //     const adminEmail = 'admin2@eldos.com';
            
        //     const user = await UserModel.findOne({email: adminEmail});
        //     if (!user) {
        //         const password = await bcrypt.hash('admin', 10);
        //         const newUser = new UserModel({
        //             id: uuidv4(),
        //             password: password,
        //             email: adminEmail,
        //             name: 'Eldos Admin',
        //             role: Role.admin.name,
        //         });
        //         await newUser.save();
        //         console.log('Admin User Created')
        //     }
            
        //     const setting = await SettingModel.findOne({});
        //     if (!setting) {
        //         const newSetting = new SettingModel({
        //             id: uuidv4(),
        //             name: 'Company Name',
        //             address: 'Street',
        //             country: 'IDN',
        //             email: adminEmail,
        //             leaveLimit: 14
        //         });
        //         await SettingModel.save(newSetting);
        //         console.log('Default Setting Created')
        //     }
        // });
}