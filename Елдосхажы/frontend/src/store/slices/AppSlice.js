import {createSlice} from "@reduxjs/toolkit";

const initialState = {
    store: '',
    currency: 'IDR'
};

export const AppSlice = createSlice({
    name: 'app',
    initialState,
    reducers: {
        setStore: (state, action) => {
            state.store = action.payload;
        },
    }
});

export const {
    setStore,
} = AppSlice.actions;

export default AppSlice;
