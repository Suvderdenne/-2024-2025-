import ApiInstance from "../utils/instance";

export const GetAttendancesByQuery = (query) => {
    return ApiInstance.get('/attendance', {params: query});
}

export const GetAttendanceById = (id) => {
    return ApiInstance.get(`/attendance/${id}`);
}

export const CreateAttendance = (params) => {
    return ApiInstance.post('/attendance', params);
}

export const UpdateAttendance = (id, params) => {
    return ApiInstance.put(`/attendance/${id}`, params);
}

export const DeleteAttendance = (ids) => {
    return ApiInstance.delete(`/attendance/${ids}`);
}