import ApiInstance from "../utils/instance";

export const GetSetting = async () => {
    return ApiInstance.get('/setting');
};

export const UpdateSetting = async (params) => {
    return ApiInstance.put(`/setting/${params.id}`, params);
};
