import {cardShadow, darkShadows} from "./shadows";

const components = (theme) => {
    return {
        MuiCssBaseline: {
            styleOverrides: {
                '*': {
                    boxSizing: 'border-box',
                },
                html: {
                    height: '100%',
                    width: '100%',
                },
                a: {
                    textDecoration: 'none',
                },
                body: {
                    height: '100%',
                    margin: 0,
                    padding: 0,
                },
                textarea: {
                    padding: 0
                },
                '#root': {
                    height: '100%',
                },
                "*[dir='rtl'] .buyNowImg": {
                    transform: 'scaleX(-1)',
                },
                '.border-none': {
                    border: '0px',
                    td: {
                        border: '0px',
                    },
                },
                '.btn-xs': {
                    minWidth: '30px !important',
                    width: '30px',
                    height: '30px',
                    borderRadius: '6px !important',
                    padding: '0px !important',
                },
                '.hover-text-primary:hover .text-hover': {
                    color: theme.palette.primary.main,
                },
                '.hoverCard:hover': {
                    scale: '1.01',
                    transition: ' 0.1s ease-in',
                },
                '.signup-bg': {
                    position: 'absolute',
                    top: 0,
                    right: 0,
                    height: '100%',
                },
                '.MuiBox-root': {
                    borderRadius: theme.shape.borderRadius,
                },
                '.MuiCardHeader-action': {
                    alignSelf: 'center !important',
                },
                '.emoji-picker-react .emoji-scroll-wrapper': {
                    overflowX: 'hidden',
                },
                '.scrollbar-container': {
                    borderRight: '0 !important',
                },
                '.theme-timeline .MuiTimelineOppositeContent-root': {
                    minWidth: '90px',
                },
                '.MuiAlert-root .MuiAlert-icon': {
                    color: 'inherit!important',
                },
                '.MuiTimelineConnector-root': {
                    width: '1px !important',
                },
                ' .simplebar-scrollbar:before': {
                    background: `${theme.palette.grey[300]} !important`,
                },
                '@keyframes gradient': {
                    '0%': {
                        backgroundPosition: '0% 50%',
                    },
                    '50%': {
                        backgroundPosition: ' 100% 50%',
                    },
                    '100% ': {
                        backgroundPosition: ' 0% 50%',
                    },
                },
                '.rounded-bars .apexcharts-bar-series.apexcharts-plot-series .apexcharts-series path': {
                    clipPath: 'inset(0 0 5% 0 round 20px)',
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 10
                },
                sizeLarge: {
                    height: 60
                },
                sizeSmall: {
                    borderRadius: 8
                }
            }
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    background: theme.palette.background.paper,
                    borderRadius: 15,
                    boxShadow: theme.palette.mode === 'dark' ? darkShadows : cardShadow,
                }
            }
        },
        MuiChip: {
            styleOverrides: {
                root: {
                    '.MuiChip-labelSmall': {
                        fontSize: 10,
                    }
                },
                sizeSmall: {
                    height: '20px !important'
                }
            }
        },
        MuiInputBase: {
            styleOverrides: {
                root: {
                    borderRadius: `10px !important`,
                },
                sizeSmall: {
                    borderRadius: `8px !important`
                },
                multiline: {
                    padding: `0 !important`
                }
            }
        },
        MuiOutlinedInput: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-notchedOutline': {
                        borderColor: theme.palette.grey['200']
                    },
                    '&:hover .MuiOutlinedInput-notchedOutline': {
                        borderColor: theme.palette.grey[300],
                    },
                },
                input: {
                    padding: '12px 14px',
                },
                inputSizeSmall: {
                    padding: '8px 14px',
                },
            },
        },
        MuiFormLabel: {
            styleOverrides: {
                root: {
                    fontSize: 12,
                    fontWeight: 500,
                },
            },
        },
        MuiPaper: {
            styleOverrides: {
                outlined: {
                    boxShadow: 'none'
                }
            }
        },
        MuiTableCell: {
            styleOverrides: {
                head: {
                    fontSize: 12,
                    fontWeight: 600,
                    color: theme.palette.grey['500'],
                    textTransform: 'uppercase'
                },
                root: {
                    fontSize: 14,
                    borderBottomColor: theme.palette.grey['200']
                }
            }
        },
        MuiTypography: {
            styleOverrides: {
                root: {
                    color: theme.palette.text.primary
                },
                subtitle2: {
                    fontWeight: 500
                }
            }
        }
    }
};

export default components;