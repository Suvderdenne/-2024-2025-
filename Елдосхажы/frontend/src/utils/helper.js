import {SetItem} from "utils/storage";

export const generateUniqueId = (length = 6) => {
    return Math.random().toString(36).substring(2, length+2);
};

export const getIp = () => {
    return fetch('http://ip-api.com/json')
        .then(response => response.json())
        .then(res => {
            if (res.status === 'success') {
                SetItem('country', res.countryCode?.toLowerCase());
            }
        });
};

export const QueryConverter = (query) => {
    return {}
};