'use strict'

const LeaveModel = require("../models/leave");
const {v4: uuidv4} = require("uuid");
const UserModel = require("../models/user");

exports.GetLeaves = async (req, res) => {
    let { sort, limit, page, keyword, ...rest } = req.query;
    const queryFind = {...rest};

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await LeaveModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0)
        .lean();

    const counts = await LeaveModel.find(queryFind, {}, {}).countDocuments();

    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    for (const item of result) {
        const user = await UserModel.findOne({id: item.userId}, {password: 0}, {}).lean();
        if (user) {
            item.user = user;
        }
    }

    return res.status(200).send({
        data: result,
        pagination: { page, pages: Math.ceil(counts / (limit ?? 20)), },
        query: {...queryFind, sort},
    });
}

exports.GetLeaveById = async (req, res) => {
    const result = await LeaveModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateLeave = async (req, res) => {
    req.body.id = uuidv4();

    if (!req.body.userId) {
        req.body.userId = req.user.id;
    }

    const result = new LeaveModel(req.body);
    await result.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateLeave = async (req, res) => {
    const { id } = req.params;

    const result = await LeaveModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteLeave = async (req, res) => {
    const { ids } = req.params;

    const result = await LeaveModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}