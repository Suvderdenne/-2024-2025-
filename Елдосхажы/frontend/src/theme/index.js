import {createTheme} from "@mui/material";
import typography from "./typography";
import {darkShadows, shadows} from "./shadows";
import {DarkThemeColors, LightThemeColors} from "./colors";
import components from "./components";

const BuildTheme = (mode) => {
    const palette = mode === 'dark' ? DarkThemeColors : LightThemeColors;
    const shadow = mode === 'dark' ? darkShadows : shadows;

    const theme = createTheme({
        palette: {
            mode: mode,
            ...palette
        },
        shadows: shadow,
        typography: { ...typography },
    });

    theme.components = components(theme);

    return theme;
};

export default BuildTheme;