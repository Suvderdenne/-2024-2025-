const BasicThemeColors = {
    primary: {
        main: '#7161ef',
        light: '#F5F4FE',
        dark: '#574BB6',
        contrastText: '#FFFFFF'
    },
    secondary: {
        main: '#CDB3F2',
        light: '#F5EFFC',
        dark: '#9C67E5',
        contrastText: '#21222D'
    },
    tertiary: {
        main: '#F886B9',
        light: '#FFEEF6',
        dark: '#C45788',
        contrastText: '#FFFFFF'
    },
};

const LightThemeColors = {
    ...BasicThemeColors,
    success: {
        main: '#34c38f',
        light: '#D2F3E7',
        dark: '#28986F',
        contrastText: '#FFFFFF'
    },
    info: {
        main: '#4cc9f0',
        light: '#CCF0FB',
        dark: '#13B5E6',
        contrastText: '#FFFFFF'
    },
    grey: {
        main: '#41424E',
        contrastText: '#FFFFFF',
        100: '#F1F1F3',
        200: '#D4D5DB',
        300: '#8D8EA0',
        400: '#656679',
        500: '#41424E',
        600: '#383943',
        700: '#21222D'
    },
    text: {
        main: '#2A3547',
        secondary: '#7C8FAC'
    },
    background: {
        default: '#fafaff',
        dark: '#f8f9fa',
        paper: '#FFFFFF',
    },
};

const DarkThemeColors = {
    ...BasicThemeColors,
    primary: {
        ...BasicThemeColors.primary,
        light: '#4E2C38'
    },
    secondary: {
        ...BasicThemeColors.secondary,
        light: '#504332'
    },
    text: {
        main: '#FFFFFF',
        primary: '#EAEFF4',
        secondary: '#7C8FAC',
    },
    action: {
        disabledBackground: 'rgba(73,82,88,0.12)',
        hoverOpacity: 0.02,
        hover: '#333F55',
    },
    divider: '#333F55',
    success: {
        main: '#13DEB9',
        light: '#1B3C48',
        dark: '#0B7E69',
        contrastText: '#FFFFFF'
    },
    grey: {
        main: '#41424E',
        contrastText: '#FFFFFF',
        700: '#F1F1F3',
        600: '#D4D5DB',
        500: '#8D8EA0',
        400: '#656679',
        300: '#41424E',
        200: '#383943',
        100: '#21222D'
    },
    background: {
        paper: '#21222D',
        dark: '#171821',
        default: '#171821',
    },
};

export { LightThemeColors, DarkThemeColors };