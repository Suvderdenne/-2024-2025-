'use strict';

const {verify} = require("jsonwebtoken");
const UserModel = require("../models/user");

exports.AuthMiddleware = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return res.status(403).json({ message: 'A token is required for authentication' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
        return res.status(403).json({ message: 'A token is required for authentication' });
    }

    const verifyToken = verify(token, process.env.JWT_SECRET);
    if (!verifyToken) {
        return res.status(401).json({ message: 'Invalid token' });
    }

    req.user = verify(token, process.env.JWT_SECRET);
    const user = await UserModel.findOne({id: req.user?.id}, {password: 0}, {}).lean();
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }
    req.user = {...req.user, ...user}

    return next();
}