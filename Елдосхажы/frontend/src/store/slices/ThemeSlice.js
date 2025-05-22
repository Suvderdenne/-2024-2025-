import {createSlice} from "@reduxjs/toolkit";

const initialState = {
    activeMode: 'light',
    activeLanguage: 'en',
    isSidebarCollapse: true,
    sidebarWidth: 270,
    toolbarHeight: 70,
};

export const ThemeSlice = createSlice({
   name: 'theme',
   initialState,
   reducers: {
       setActiveLanguage: (state, action) => {
           state.activeLanguage = action.payload;
       },
       setThemeMode: (state) => {
           console.log('Action', state.activeMode);

           state.activeMode = state.activeMode === 'light' ? 'dark' : 'light';
       },
       setSidebarCollapse: (state, action) => {
            state.isSidebarCollapse = action.payload ?? !state.isSidebarCollapse;
       },
   }
});

export const {
    setActiveLanguage,
    setThemeMode,
    setSidebarCollapse,
} = ThemeSlice.actions;

export default ThemeSlice;
