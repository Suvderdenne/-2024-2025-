'use strict'

const ProjectModel = require("../models/project");
const {v4: uuidv4} = require("uuid");
const NotificationModel = require("../models/notification");
const moment = require("moment");
const UserModel = require("../models/user");

exports.GetProjects = async (req, res) => {
    let { sort, limit, page, keyword, dashboard, ...rest } = req.query;
    const queryFind = {...rest};

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await ProjectModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0)
        .lean();

    const counts = await ProjectModel.find(queryFind, {}, {}).countDocuments();

    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    if (dashboard === 'true') {
        const currentYear = new Date().getFullYear();

        const completedData = result.reduce((acc, transaction) => {
            if (transaction?.completedAt) {
                const month = moment(transaction.completedAt.$date).month();
                const year = moment(transaction.createdAt.$date).year();

                if (currentYear === year) {
                    if (!acc[month]) {
                        acc[month] = {
                            month: month,
                            count: 1
                        };
                    } else {
                        acc[month].count += 1;
                    }
                    return acc;
                }
            }

            return {};
        }, {});

        const progressing = {};
        result.forEach(item => {
            if (item.status) {
                const month = moment(item.createdAt).month();
                const year = moment(item.createdAt.$date).year();

                if (currentYear === year) {
                    if (!progressing[month]) {
                        progressing[month] = {
                            month: month,
                            count: 1
                        };
                    } else {
                        progressing[month].count += 1;
                    }
                }
            }
        })

        return res.status(200).send({data: {completed: completedData, progressing: progressing}});
    }

    return res.status(200).send({
        data: result,
        pagination: { page, pages: Math.ceil(counts / (limit ?? 20)), },
        query: {...queryFind, sort},
    });
}

exports.GetProjectById = async (req, res) => {
    const result = await ProjectModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateProject = async (req, res) => {
    req.body.id = uuidv4();
    const result = new ProjectModel(req.body);
    await result.save();

    const notification = new NotificationModel({
        id: uuidv4(),
        userId: req.user?.id,
        title: 'Шинэ төсөл',
        description: ` "${req.body.name}" нэртэй шинэ төсөл үүсгэсэн`
    });
    await notification.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateProject = async (req, res) => {
    const { id } = req.params;

    if (!req.body.status || req.body.progress === 100) {
        req.body.completedAt = new Date();
    }

    const result = await ProjectModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteProject = async (req, res) => {
    const { ids } = req.params;

    const result = await ProjectModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}