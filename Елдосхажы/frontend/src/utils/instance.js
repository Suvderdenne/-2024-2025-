import axios from 'axios';
import {GetItem} from "./storage";
import {StorageKey} from "../constants/constants";

const API_URL = `${process.env.REACT_APP_BASE_API_URL}/api`

const ApiInstance = axios.create({
    baseURL: API_URL,
    timeout: 10000,
    // headers: {'X-Custom-Header': 'foobar'}
});

ApiInstance.interceptors.request.use(async (config) => {
    const token = await GetItem(StorageKey.TOKEN);
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
}, (error) => {
    return Promise.reject(error);
})

export default ApiInstance;