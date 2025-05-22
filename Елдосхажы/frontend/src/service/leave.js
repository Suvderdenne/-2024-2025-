import ApiInstance from "../utils/instance";

export const GetLeavesByQuery = (query) => {
    return ApiInstance.get('/leave', {params: query});
}

export const GetLeaveById = (id) => {
    return ApiInstance.get(`/leave/${id}`);
}

export const CreateLeave = (params) => {
    return ApiInstance.post('/leave', params);
}

export const UpdateLeave = (id, params) => {
    return ApiInstance.put(`/leave/${id}`, params);
}

export const DeleteLeave = (ids) => {
    return ApiInstance.delete(`/leave/${ids}`);
}