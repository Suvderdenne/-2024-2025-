import ApiInstance from "../utils/instance";

export const GetDepartmentsByQuery = (query) => {
    return ApiInstance.get('/department', {params: query});
}

export const GetDepartmentById = (id) => {
    return ApiInstance.get(`/department/${id}`);
}

export const CreateDepartment = (params) => {
    return ApiInstance.post('/department', params);
}

export const UpdateDepartment = (id, params) => {
    return ApiInstance.put(`/department/${id}`, params);
}

export const DeleteDepartment = (ids) => {
    return ApiInstance.delete(`/department/${ids}`);
}