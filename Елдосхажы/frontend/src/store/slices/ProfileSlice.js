import {createSlice} from "@reduxjs/toolkit";

const initialState = {
    profile: null,
    role: null
};
export const ProfileSlice = createSlice({
    name: 'profile',
    initialState,
    reducers: {
        setProfile: (state, action) => {
            state.profile = action.payload;
            state.role = action.payload?.role;
        },
    }
});

export const {
    setProfile,
} = ProfileSlice.actions;

export default ProfileSlice;
