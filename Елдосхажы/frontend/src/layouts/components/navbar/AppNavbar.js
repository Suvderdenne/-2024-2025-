import {AppBar, Box, IconButton, Stack, styled, Toolbar, useTheme} from "@mui/material";
import {useDispatch, useSelector} from "react-redux";
import {setSidebarCollapse} from "../../../store/slices/ThemeSlice";
import Profile from "../Profile";
// import Profile from "layouts/components/Profile";
// import Notifications from "layouts/components/Notifications";
// import {useDispatch, useSelector} from "store";
// import {setSidebarCollapse} from "store/slices/ThemeSlice";
const AppNavbar = () => {
    const themeSetting = useSelector(state => state.theme);
    const dispatch = useDispatch();
    const theme = useTheme();

    const AppBarStyled = styled(AppBar)(({ theme }) => ({
        boxShadow: 'none',
        background: theme.palette.background.default,
        justifyContent: 'center',
        backdropFilter: 'blur(4px)',
        [theme.breakpoints.up('lg')]: {
            minHeight: themeSetting.toolbarHeight,
        },
    }));

    const ToolbarStyled = styled(Toolbar)(({ theme }) => ({
        color: theme.palette.text.secondary,
    }));

    return (
        <AppBarStyled position="sticky" color="default">
            <ToolbarStyled>
                <IconButton
                    color="inherit"
                    aria-label="menu"
                    onClick={() => dispatch(setSidebarCollapse())}
                >
                    <svg width="20" height="18" viewBox="0 0 20 18" fill={theme.palette.text.secondary} xmlns="http://www.w3.org/2000/svg">
                        <g clipPath="url(#clip0_115_9)">
                            <path d="M10.5556 0H1.38889C0.621827 0 0 0.746192 0 1.66667C0 2.58714 0.621827 3.33333 1.38889 3.33333H10.5556C11.3226 3.33333 11.9444 2.58714 11.9444 1.66667C11.9444 0.746192 11.3226 0 10.5556 0Z" fill={theme.palette.text.secondary}/>
                            <path d="M18.6111 7H1.38889C0.621827 7 0 7.74619 0 8.66667C0 9.58714 0.621827 10.3333 1.38889 10.3333H18.6111C19.3782 10.3333 20 9.58714 20 8.66667C20 7.74619 19.3782 7 18.6111 7Z" fill={theme.palette.text.secondary}/>
                            <path d="M14.4444 14H1.38889C0.621827 14 0 14.7462 0 15.6667C0 16.5871 0.621827 17.3333 1.38889 17.3333H14.4444C15.2115 17.3333 15.8333 16.5871 15.8333 15.6667C15.8333 14.7462 15.2115 14 14.4444 14Z" fill={theme.palette.text.secondary}/>
                        </g>
                        <defs>
                            <clipPath id="clip0_115_9">
                                <rect width="20" height="17.3333" fill={theme.palette.text.secondary}/>
                            </clipPath>
                        </defs>
                    </svg>
                </IconButton>
                <Box flexGrow={1} />
                <Stack spacing={1} direction="row" alignItems="center">
                    {/*<Notifications />*/}
                    <Profile />
                </Stack>
            </ToolbarStyled>
        </AppBarStyled>
    );
};

export default AppNavbar;