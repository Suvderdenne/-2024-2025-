import ApiInstance from "../utils/instance";

export const GetNotificationsByQuery = (query) => {
    return ApiInstance.get('/notification', {params: query});
}

export const GetNotificationById = (id) => {
    return ApiInstance.get(`/notification/${id}`);
}

export const CreateNotification = (params) => {
    return ApiInstance.post('/notification', params);
}

export const UpdateNotification = (id, params) => {
    return ApiInstance.put(`/notification/${id}`, params);
}

export const DeleteNotification = (ids) => {
    return ApiInstance.delete(`/notification/${ids}`);
}