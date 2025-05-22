import ApiInstance from "../utils/instance";

export const GetUsersByQuery = (query) => {
    return ApiInstance.get('/user', {params: query});
}

export const GetUserById = (id) => {
    return ApiInstance.get(`/user/${id}`);
}

export const CreateUser = (params) => {
    return ApiInstance.post('/user', params);
}

export const UpdateUser = (id, params) => {
    return ApiInstance.put(`/user/${id}`, params);
}

export const DeleteUser = (ids) => {
    return ApiInstance.delete(`/user/${ids}`);
}