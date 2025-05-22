import ApiInstance from "../utils/instance";

export const GetAnnouncementsByQuery = (query) => {
    return ApiInstance.get('/announcement', {params: query});
}

export const GetAnnouncementById = (id) => {
    return ApiInstance.get(`/announcement/${id}`);
}

export const CreateAnnouncement = (params) => {
    return ApiInstance.post('/announcement', params);
}

export const UpdateAnnouncement = (id, params) => {
    return ApiInstance.put(`/announcement/${id}`, params);
}

export const DeleteAnnouncement = (ids) => {
    return ApiInstance.delete(`/announcement/${ids}`);
}