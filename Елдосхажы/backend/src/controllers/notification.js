'use strict'

const NotificationModel = require("../models/notification");
const {v4: uuidv4} = require("uuid");

exports.GetNotifications = async (req, res) => {
    let { sort, limit, page, keyword, ...rest } = req.query;
    const queryFind = {...rest};

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await NotificationModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0);

    const counts = await NotificationModel.find(queryFind, {}, {}).countDocuments();

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

exports.GetNotificationById = async (req, res) => {
    const result = await NotificationModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateNotification = async (req, res) => {
    req.body.id = uuidv4();

    const result = new NotificationModel(req.body);
    await result.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateNotification = async (req, res) => {
    const { id } = req.params;

    const result = await NotificationModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteNotification = async (req, res) => {
    const { ids } = req.params;

    const result = await NotificationModel.deleteMany({
        id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}