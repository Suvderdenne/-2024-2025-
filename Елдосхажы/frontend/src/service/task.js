import ApiInstance from "../utils/instance";

export const GetTasksByQuery = (query) => {
    return ApiInstance.get('/task', {params: query});
}

export const GetTaskById = (id) => {
    return ApiInstance.get(`/task/${id}`);
}

export const CreateTask = (params) => {
    return ApiInstance.post('/task', params);
}

export const UpdateTask = (id, params) => {
    return ApiInstance.put(`/task/${id}`, params);
}

export const DeleteTask = (ids) => {
    return ApiInstance.delete(`/task/${ids}`);
}