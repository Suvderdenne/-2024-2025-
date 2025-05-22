import ApiInstance from "../utils/instance";

export const CheckInitial = async () => {
    return ApiInstance.get('/initial');
};

export const InstallService = async (params) => {
    return ApiInstance.post('/install', params);
};
