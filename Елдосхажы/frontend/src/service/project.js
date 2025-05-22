import ApiInstance from "../utils/instance";

export const GetProjectsByQuery = (query) => {
    return ApiInstance.get('/project', {params: query});
}

export const GetProjectById = (id) => {
    return ApiInstance.get(`/project/${id}`);
}

export const CreateProject = (params) => {
    return ApiInstance.post('/project', params);
}

export const UpdateProject = (id, params) => {
    return ApiInstance.put(`/project/${id}`, params);
}

export const DeleteProject = (ids) => {
    return ApiInstance.delete(`/project/${ids}`);
}