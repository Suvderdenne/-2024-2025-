import ApiInstance from "../utils/instance";

export const LoginService = async (params) => {
    return ApiInstance.post('/login', params);
};

export const AuthTokenCheck = async () => {

};