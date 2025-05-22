'use strict'

const UserModel = require("../models/user");
const {v4: uuidv4} = require("uuid");
const bcrypt = require("bcryptjs");

exports.GetUsers = async (req, res) => {
    let { sort, limit, page, keyword, ...rest } = req.query;
    const queryFind = {...rest};

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await UserModel
        .find(queryFind, {password: 0}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0);

    const counts = await UserModel.find(queryFind, {}, {}).countDocuments();

    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result,
        pagination: { page, pages: Math.ceil(counts / (limit ?? 20)), },
        query: {...queryFind, sort},
    });
}

exports.GetUserById = async (req, res) => {
    const result = await UserModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateUser = async (req, res) => {
    req.body.id = uuidv4();
    req.body.password = await bcrypt.hash(req.body.password, 10);

    const result = new UserModel(req.body);
    await result.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateUser = async (req, res) => {
    const { id } = req.params;

    if (req.body?.password) {
        req.body.password = await bcrypt.hash(req.body.password, 10);
    }

    const result = await UserModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteUser = async (req, res) => {
    const { ids } = req.params;

    const result = await UserModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}