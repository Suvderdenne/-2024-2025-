import ApiInstance from "../utils/instance";

export const GetDesignationsByQuery = (query) => {
    return ApiInstance.get('/designation', {params: query});
}

export const GetDesignationById = (id) => {
    return ApiInstance.get(`/designation/${id}`);
}

export const CreateDesignation = (params) => {
    return ApiInstance.post('/designation', params);
}

export const UpdateDesignation = (id, params) => {
    return ApiInstance.put(`/designation/${id}`, params);
}

export const DeleteDesignation = (ids) => {
    return ApiInstance.delete(`/designation/${ids}`);
}