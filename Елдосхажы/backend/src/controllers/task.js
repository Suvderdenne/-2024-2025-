'use strict'

const TaskModel = require("../models/task");
const {v4: uuidv4} = require("uuid");
const NotificationModel = require("../models/notification");
const ProjectModel = require("../models/project");
const UserModel = require("../models/user");

exports.GetTasks = async (req, res) => {
    let { sort, limit, page, keyword, ...rest } = req.query;
    const queryFind = {...rest};

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await TaskModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0)
        .lean();

    const counts = await TaskModel.find(queryFind, {}, {}).countDocuments();

    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    for (const item of result) {
        const project = await ProjectModel.findOne({id: item.projectId}, {}, {}).lean();
        if (project) {
            item.project = project;
        }

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

exports.GetTaskById = async (req, res) => {
    const result = await TaskModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateTask = async (req, res) => {
    req.body.id = uuidv4();
    const result = new TaskModel(req.body);
    await result.save();

    const notification = new NotificationModel({
        id: uuidv4(),
        userId: req.user?.id,
        title: 'Шинэ даалгавар',
        description: `${req.user?.name}-т шинэ даалгавар өгөв`
    });
    await notification.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateTask = async (req, res) => {
    const { id } = req.params;

    const result = await TaskModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteTask = async (req, res) => {
    const { ids } = req.params;

    const result = await TaskModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}