'use strict'

const UserModel = require('../models/user');
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.Login = async (req, res) => {
    const { email, password } = req.body;
    const errors = [];

    if (!email || !password) {
        return res.status(404).send({ data: 'Email and password are required!'});
    }

    const user = await UserModel.findOne({email: email}).lean();
    if (!user) {
        return res.status(404).send({ data: 'User not found!'});
    }

    const passwordValid = await bcrypt.compareSync(
        password,
        user.password
    );
    if (!passwordValid) {
        return res.status(404).send({ data: 'Password is not valid!'});
    }

    if (errors.length > 0) {
        return res.status(400).send({
            data: errors
        });
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET);

    await UserModel.findOneAndUpdate({id: user.id}, {...user, lastActive: new Date()});

    return res.status(200).send({
        data: {
            token: token,
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role
        }
    });
}

exports.RefreshToken = async (req, res) => {

}