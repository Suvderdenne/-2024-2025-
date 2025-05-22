import {configureStore} from "@reduxjs/toolkit";
import {
    useDispatch as useAppDispatch,
    useSelector as useAppSelector,
} from 'react-redux';
import ThemeSlice from "./slices/ThemeSlice";
import AppSlice from "./slices/AppSlice";
import ProfileSlice from "./slices/ProfileSlice";

const store = configureStore({
    reducer: {
        app: AppSlice.reducer,
        profile: ProfileSlice.reducer,
        theme: ThemeSlice.reducer
    }
});

export const useDispatch = () => useAppDispatch();
export const useSelector = useAppSelector;

export default store;