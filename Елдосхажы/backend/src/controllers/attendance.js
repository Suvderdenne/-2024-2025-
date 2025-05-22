'use strict'

const AttendanceModel = require("../models/attendance");
const UserModel = require("../models/user");
const NotificationModel = require("../models/notification");
const {v4: uuidv4} = require("uuid");
const dayjs = require("dayjs");

exports.GetAttendances = async (req, res) => {
    let { sort, limit, page, keyword, today, time, ...rest } = req.query;
    const queryFind = {...rest};

    if (today === 'true' || time) {
        let todayStart = dayjs().startOf('day').toDate();
        let todayEnd = dayjs().endOf('day').toDate();

        if (time === 'week') {
            todayStart = dayjs().startOf('week').toDate();
            todayEnd = dayjs().endOf('week').toDate();
        } else if (time === 'month') {
            todayStart = dayjs().startOf('week').toDate();
            todayEnd = dayjs().endOf('week').toDate();
        }

        queryFind['$and'] = [{checkIn: {$gte: todayStart, $lte: todayEnd}}, {...rest}]
    }

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await AttendanceModel
        .find(queryFind, {}, {})
        .populate('userId')
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0)
        .lean();

    const counts = await AttendanceModel.find(queryFind, {}, {}).countDocuments();

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

exports.GetAttendanceById = async (req, res) => {
    const result = await AttendanceModel.findOne({id: req.params.id}, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateAttendance = async (req, res) => {
    req.body.id = uuidv4();

    const result = new AttendanceModel(req.body);
    await result.save();

    // Add Notification
    const notification = new NotificationModel({
        id: uuidv4(),
        userId: req.user?.id,
        title: 'Ирц',
        description: `Ажилтан ${req.user?.name} ${dayjs().format('hh:mm')} цагт ирц бүртгүүлсэн`
    });
    await notification.save();

    return res.status(200).send({
        data: req.body
    });
}

exports.UpdateAttendance = async (req, res) => {
    const { id } = req.params;

    const result = await AttendanceModel.findOneAndUpdate({id: id}, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteAttendance = async (req, res) => {
    const { ids } = req.params;

    const result = await AttendanceModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}