import {Box, Drawer, useMediaQuery, useTheme} from "@mui/material";
import Logo from "../../components/Logo";
import SidebarItems from "./SidebarItems";
import {useDispatch, useSelector} from "react-redux";
import {setSidebarCollapse} from "../../../store/slices/ThemeSlice";

const AppSidebar = () => {
    const lgUp = useMediaQuery((theme) => theme.breakpoints.up('lg'));
    const themeSetting = useSelector((state) => state.theme);
    const dispatch = useDispatch();
    const theme = useTheme();
    const toggleWidth = !themeSetting.isSidebarCollapse ? 0 : themeSetting.sidebarWidth;

    // Desktop
    if (lgUp) {
        return (
            <Box
                sx={{
                    width: toggleWidth,
                    flexShrink: 0,
                }}
            >
                <Drawer
                    anchor="left"
                    open={themeSetting.isSidebarCollapse}
                    onClose={() => dispatch(setSidebarCollapse())}
                    variant="permanent"
                    PaperProps={{
                        sx: {
                            background: 'transparent',
                            transition: theme.transitions.create('width', {
                                duration: theme.transitions.duration.shortest,
                            }),
                            width: toggleWidth,
                            boxSizing: 'border-box',
                        },
                    }}
                >
                    <Box
                        sx={{
                            maxHeight: '100vh',
                        }}>
                        <Box height={20}/>
                        <Logo />
                        <SidebarItems />
                    </Box>
                </Drawer>
            </Box>
        );
    }

    // Mobile
    return (
        <Drawer
            anchor="left"
            open={themeSetting.isSidebarCollapse}
            onClose={() => dispatch(setSidebarCollapse())}
            variant="temporary"
            PaperProps={{
                sx: {
                    width: toggleWidth,
                    background: theme.palette.background.default,
                    border: '0 !important',
                    boxShadow: (theme) => theme.shadows[8],
                },
            }}
        >
            {/* ------------------------------------------- */}
            {/* Logo */}
            {/* ------------------------------------------- */}
            <Box px={2} py={2}>
                <Logo />
            </Box>
            {/* ------------------------------------------- */}
            {/* AppSidebar For Mobile */}
            {/* ------------------------------------------- */}
            <SidebarItems />
        </Drawer>
    );
};

export default AppSidebar;