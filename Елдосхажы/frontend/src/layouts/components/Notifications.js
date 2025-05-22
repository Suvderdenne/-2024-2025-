import {useState} from "react";
import {Avatar, Badge, Box, Button, Chip, IconButton, Menu, MenuItem, Stack, Typography} from "@mui/material";
import {NotificationsRounded} from "@mui/icons-material";

const notifications = [
    {
        avatar: "/images/profile/user-1.jpg",
        title: "Roman Joined the Team!",
        subtitle: "Congratulate him",
    },
    {
        avatar: "/images/profile/user-2.jpg",
        title: "New message received",
        subtitle: "Salma sent you new message",
    },
];

const Notifications = () => {
    const [anchorEl2, setAnchorEl2] = useState(null);

    const handleClick2 = (event) => {
        setAnchorEl2(event.currentTarget);
    };

    const handleClose2 = () => {
        setAnchorEl2(null);
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
                    color: anchorEl2 ? 'primary.main' : 'text.secondary',
                }}
                onClick={handleClick2}
            >
                <Badge variant="dot" color="primary">
                    <NotificationsRounded size="21" />
                </Badge>
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
                        width: '360px',
                    },
                }}
            >
                <Stack direction="row" py={2} px={4} justifyContent="space-between" alignItems="center">
                    <Typography variant="h6">Notifications</Typography>
                    <Chip label="5 new" color="primary" size="small" />
                </Stack>
                <Box sx={{ height: '385px', overflowY: 'scroll' }}>
                    {notifications.map((notification, index) => (
                        <Box key={index}>
                            <MenuItem sx={{ py: 2, px: 4 }}>
                                <Stack direction="row" spacing={2}>
                                    <Avatar
                                        src={notification.avatar}
                                        alt={notification.avatar}
                                        sx={{
                                            width: 48,
                                            height: 48,
                                        }}
                                    />
                                    <Box>
                                        <Typography
                                            variant="subtitle2"
                                            color="textPrimary"
                                            fontWeight={600}
                                            noWrap
                                            sx={{
                                                width: '240px',
                                            }}
                                        >
                                            {notification.title}
                                        </Typography>
                                        <Typography
                                            color="textSecondary"
                                            variant="subtitle2"
                                            sx={{
                                                width: '240px',
                                            }}
                                            noWrap
                                        >
                                            {notification.subtitle}
                                        </Typography>
                                    </Box>
                                </Stack>
                            </MenuItem>
                        </Box>
                    ))}
                </Box>
                <Box p={3} pb={1}>
                    <Button href="/apps/email" variant="outlined" color="primary" fullWidth>
                        See all Notifications
                    </Button>
                </Box>
            </Menu>
        </Box>
    );
};

export default Notifications;