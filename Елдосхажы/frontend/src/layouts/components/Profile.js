import {useState} from "react";
import {Avatar, Box, Button, Divider, IconButton, Menu, Stack, Typography} from "@mui/material";
import ProfileMenus from "../constants/profile";
import {RemoveItem} from "utils/storage";
import {StorageKey} from "constants/constants";
import {Link, useNavigate} from "react-router-dom";

const Profile = () => {
    const navigate = useNavigate();
    const [anchorEl2, setAnchorEl2] = useState(null);
    const handleClick2 = (event) => {
        setAnchorEl2(event.currentTarget);
    };
    const handleClose2 = () => {
        setAnchorEl2(null);
    };

    const logout = async () => {
        await RemoveItem(StorageKey.TOKEN);
        await RemoveItem(StorageKey.USER);
        setTimeout(() => {
            navigate('/');
        }, 1000);
    };

    return (
        <Box>
            <IconButton
                size="large"
                aria-label="show 11 new notifications"
                color="inherit"
                aria-controls="msgs-menu"
                aria-haspopup="true"
                sx={{
                    ...(typeof anchorEl2 === 'object' && {
                        color: 'primary.main',
                    }),
                }}
                onClick={handleClick2}
            >
                <Avatar
                    src={"/images/profile.svg"}
                    alt={'ProfileImg'}
                    sx={{
                        width: 40,
                        height: 40,
                    }}
                />
            </IconButton>
            <Menu
                id="msgs-menu"
                anchorEl={anchorEl2}
                keepMounted
                open={Boolean(anchorEl2)}
                onClose={handleClose2}
                anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
                transformOrigin={{ horizontal: 'right', vertical: 'top' }}
                sx={{
                    '& .MuiMenu-paper': {
                        width: '300px',
                        p: 4,
                    },
                }}
            >
                <Typography variant="h5">User Profile</Typography>
                <Stack direction="row" py={3} spacing={2} alignItems="center">
                    <Avatar src={"/images/profile.svg"} alt={"ProfileImg"} sx={{ width: 50, height: 50 }} />
                    <Box>
                        <Typography variant="subtitle2" color="textPrimary" fontWeight={600}>
                            Admin
                        </Typography>
                        <Typography variant="caption" color="textSecondary">
                            Admin
                        </Typography>
                    </Box>
                </Stack>
                <Divider />
                {ProfileMenus.map(({icon: Component, ...profile}) => (
                    <Box key={profile.title}>
                        <Box sx={{ py: 2, px: 0 }} className="hover-text-primary">
                            <Link to={profile.href}>
                                <Stack direction="row" spacing={2}>
                                    <Box
                                        width="45px"
                                        height="45px"
                                        bgcolor="primary.light"
                                        display="flex"
                                        alignItems="center"
                                        justifyContent="center"
                                    >
                                        <Component
                                            sx={{
                                                width: 24,
                                                height: 24,
                                                borderRadius: 0,
                                            }}
                                        />
                                    </Box>
                                    <Box>
                                        <Typography
                                            variant="subtitle2"
                                            fontWeight={600}
                                            color="textPrimary"
                                            className="text-hover"
                                            noWrap
                                            sx={{
                                                width: '240px',
                                            }}
                                        >
                                            {profile.title}
                                        </Typography>
                                        <Typography
                                            color="textSecondary"
                                            variant="subtitle2"
                                            sx={{
                                                width: '240px',
                                            }}
                                            noWrap
                                        >
                                            {profile.subtitle}
                                        </Typography>
                                    </Box>
                                </Stack>
                            </Link>
                        </Box>
                    </Box>
                ))}
                <Box mt={2}>
                    <Button onClick={logout} variant="outlined" color="primary" fullWidth>
                        Logout
                    </Button>
                </Box>
            </Menu>
        </Box>
    );
};

export default Profile;