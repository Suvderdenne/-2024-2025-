'use strict'

const ExpenseModel = require("../models/expense");
const NotificationModel = require("../models/notification");
const {v4: uuidv4} = require("uuid");
const dayjs = require("dayjs");
const moment = require("moment/moment");

exports.GetExpenses = async (req, res) => {
    let { sort, limit, page, keyword, time, dashboard, ...rest } = req.query;
    const queryFind = {...rest};

    if (time) {
        let todayStart = dayjs().startOf('day').toDate();
        let todayEnd = dayjs().endOf('day').toDate();

        if (time === 'week') {
            todayStart = dayjs().startOf('week').toDate();
            todayEnd = dayjs().endOf('week').toDate();
        } else if (time === 'month') {
            todayStart = dayjs().startOf('week').toDate();
            todayEnd = dayjs().endOf('week').toDate();
        }

        queryFind['$and'] = [{date: {$gte: todayStart, $lte: todayEnd}}]
    }

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await ExpenseModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0);

    const counts = await ExpenseModel.find(queryFind, {}, {}).countDocuments();

    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    if (dashboard === 'true') {
        const currentYear = new Date().getFullYear();
        const currentMonth = new Date().getMonth();
        let thisMonth = 0;

        const expense = Array(12).fill(0);
        result.forEach(item => {
            const month = moment(item.date).month();
            const year = moment(item.date.$date).year();

            if (currentYear === year) {
                if (!expense[month]) {
                    expense[month] = item.amount;
                } else {
                    expense[month] += item.amount;
                }

                if (currentMonth === month) {
                    thisMonth += item.amount;
                }
            }
        })

        return res.status(200).send({data: {annual: expense, month: thisMonth}});
    }

    return res.status(200).send({
        data: result,
        pagination: { page, pages: Math.ceil(counts / (limit ?? 20)), },
        query: {...queryFind, sort},
    });
}

exports.GetExpenseById = async (req, res) => {
    const result = await ExpenseModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateExpense = async (req, res) => {
    req.body.id = uuidv4();
    req.body.createdBy = req.user?.id;

    const result = new ExpenseModel(req.body);
    await result.save();

    // Add Notification
    const notification = new NotificationModel({
        id: uuidv4(),
        userId: req.user?.id,
        title: 'Шинэ зарлага',
        description: 'Шинэ зарлага гарсан'
    });
    await notification.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateExpense = async (req, res) => {
    const { id } = req.params;

    const result = await ExpenseModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteExpense = async (req, res) => {
    const { ids } = req.params;

    const result = await ExpenseModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}