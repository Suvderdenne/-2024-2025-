import {List, ListItemButton, ListItemIcon, ListItemText, styled, Typography, useTheme} from "@mui/material";
import {CircleOutlined} from "@mui/icons-material";
import {cardShadow} from "theme/shadows";
import {NavLink} from "react-router-dom";

const NavItem = ({ item, level, pathDirect, hideMenu }) => {
    const Icon = item?.icon;
    const theme = useTheme();
    let baseHref = '/app';
    const active = pathDirect === `${baseHref}${item?.href}`

    const itemIcon =
        level > 1 ? (
            <CircleOutlined sx={{ fontSize: 8 }}/>
        ) : (
            <Icon sx={{ fontSize: 18 }} />
        );

    const ListItemStyled = styled(ListItemButton)(() => ({
        whiteSpace: "nowrap",
        marginBottom: "2px",
        padding: "8px 10px",
        borderRadius: 10,
        backgroundColor: active ? level > 1 ? "transparent !important"
            : theme.palette.primary.main : "inherit",
        color: active ? `white !important`
                : theme.palette.text.secondary,
        paddingLeft: hideMenu ? "10px" : level > 2 ? `${level * 15}px` : "10px",
        "&:hover": {
            backgroundColor: theme.palette.primary.contrastText,
            boxShadow: cardShadow,
            color: `${theme.palette.primary.main} !important`,
            '.MuiTypography-root': {
                color: `${theme.palette.primary.main} !important`,
            }
        },
        "&.Mui-selected": {
            color: "white",
            backgroundColor: theme.palette.primary.main,
            "&:hover": {
                backgroundColor: theme.palette.primary.main,
                color: "white",
            },
        },
        '.MuiTypography-root': {
            fontWeight: active && level > 1 ? 600 : 400,
            color: active
                    ? level > 1 ? theme.palette.primary.main : `white !important`
                    : theme.palette.text.secondary,
        }
    }));

    return (
        <List component="li" disablePadding key={item?.id && item.title}>
            <NavLink to={`${baseHref}${item.href}`}>
                <ListItemStyled
                    disabled={item?.disabled}
                    selected={pathDirect === item?.href}
                    // onClick={onClick}
                >
                    <ListItemIcon
                        sx={{
                            minWidth: "36px",
                            p: "3px 0",
                            paddingLeft: level > 1 ? 1 : 0,
                            marginRight: 1.5,
                            color:
                                level > 1 && pathDirect === item?.href
                                    ? `${theme.palette.primary.main}!important`
                                    : "inherit",
                        }}
                    >
                        {itemIcon}
                    </ListItemIcon>
                    <ListItemText>
                        {hideMenu ? "" : <>{item?.title}</>}
                        <br />
                        {item?.subtitle ? (
                            <Typography variant="caption">
                                {hideMenu ? "" : item?.subtitle}
                            </Typography>
                        ) : (
                            ""
                        )}
                    </ListItemText>
                </ListItemStyled>
            </NavLink>
        </List>
    );
};

export default NavItem;