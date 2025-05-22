'use strict'

const { v4: uuidv4 } = require('uuid');
const dayjs = require('dayjs');
const AnnouncementModel = require("../models/announcement");
const DepartmentModel = require("../models/department");

exports.GetAnnouncements = async (req, res) => {
    let { sort, limit, page, keyword, active, ...rest } = req.query;
    const queryFind = {...rest};

    if (active === 'true') {
        const currentDate = new Date();
        queryFind['$and'] = [
            { startDate: { $lte: currentDate } },
            { endDate: { $gte: currentDate } }
        ]
    }
    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await AnnouncementModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0);

    const counts = await AnnouncementModel.find(queryFind, {}, {}).countDocuments();

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

exports.GetAnnouncementById = async (req, res) => {
    const result = await AnnouncementModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateAnnouncement = async (req, res) => {
    req.body.id = uuidv4();

    const result = new AnnouncementModel(req.body);
    await result.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateAnnouncement = async (req, res) => {
    const { id } = req.params;

    const result = await AnnouncementModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteAnnouncement = async (req, res) => {
    const { ids } = req.params;

    const result = await AnnouncementModel.deleteMany({
        _id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}