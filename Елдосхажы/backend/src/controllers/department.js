'use strict'

const DepartmentModel = require("../models/department");
const {v4: uuidv4} = require("uuid");

exports.GetDepartments = async (req, res) => {
    let { sort, limit, page, keyword, ...rest } = req.query;
    const queryFind = {...rest};

    if (keyword) queryFind.name = { $regex: keyword, $options: 'i' }
    if (sort) {
        sort = sort.split(',');
        if (sort.length > 0) sort = { [sort[0]]: sort[1]};
    }

    let result = await DepartmentModel
        .find(queryFind, {}, {})
        .sort(sort)
        .limit(limit)
        .skip(page ? limit * page : 0);

    const counts = await DepartmentModel.find(queryFind, {}, {}).countDocuments();

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

exports.GetDepartmentById = async (req, res) => {
    const result = await DepartmentModel.findById(req.params.id, {}, {});
    if (!result) {
        return res.status(404).send({
            data: 'Data not found!'
        });
    }

    return res.status(200).send({
        data: result
    });
}

exports.CreateDepartment = async (req, res) => {
    req.body.id = uuidv4();

    const result = new DepartmentModel(req.body);
    await result.save();

    return res.status(200).send({
        data: result
    });
}

exports.UpdateDepartment = async (req, res) => {
    const { id } = req.params;

    const result = await DepartmentModel.findByIdAndUpdate(id, req.body, {});

    return res.status(200).send({
        data: result
    });
}

exports.DeleteDepartment = async (req, res) => {
    const { ids } = req.params;

    const result = await DepartmentModel.deleteMany({
        id: { '$in': ids.split(',') }
    }, {});

    return res.status(200).send({
        data: result
    });
}