import ApiInstance from "../utils/instance";

export const GetExpensesByQuery = (query) => {
    return ApiInstance.get('/expense', {params: query});
}

export const GetExpenseById = (id) => {
    return ApiInstance.get(`/expense/${id}`);
}

export const CreateExpense = (params) => {
    return ApiInstance.post('/expense', params);
}

export const UpdateExpense = (id, params) => {
    return ApiInstance.put(`/expense/${id}`, params);
}

export const DeleteExpense = (ids) => {
    return ApiInstance.delete(`/expense/${ids}`);
}