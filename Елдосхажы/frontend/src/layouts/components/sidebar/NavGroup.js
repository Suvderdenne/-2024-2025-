import {ListSubheader, styled} from "@mui/material";
import {MoreHorizRounded} from "@mui/icons-material";

const NavGroup = ({ item, hideMenu }) => {
    const ListSubheaderStyle = styled((props) => (
        <ListSubheader disableSticky {...props} />
    ))(({ theme }) => ({
        ...theme.typography.overline,
        fontWeight: '700',
        marginTop: theme.spacing(3),
        marginBottom: theme.spacing(0),
        color: 'text.Primary',
        lineHeight: '26px',
        padding: '3px 12px',
        marginLeft: hideMenu ? '' : '-10px',
    }));

    return (
        <ListSubheaderStyle>{hideMenu ? <MoreHorizRounded sx={{ fontSize: 14  }} /> : item?.subheader}</ListSubheaderStyle>
    );
};

export default NavGroup;