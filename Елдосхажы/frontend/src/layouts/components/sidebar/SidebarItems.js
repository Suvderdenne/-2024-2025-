import {useDispatch, useSelector} from "store";
import {Box, List} from "@mui/material";
import NavGroup from "./NavGroup";
import NavCollapse from "./NavCollapse";
import NavItem from "./NavItem";
import Menus from "../../constants/menus";
import {setSidebarCollapse} from "store/slices/ThemeSlice";
import {useLocation} from "react-router-dom";
import {Role} from "../../../constants/constants";

const SidebarItems = () => {
    const pathname = useLocation().pathname;
    const pathDirect = pathname.replace('/app/[slug]', '');
    const pathWithoutLastPart = pathname.slice(0, pathname.lastIndexOf('/'));
    const dispatch = useDispatch();
    const { role } = useSelector(state => state.profile);

    return (
        <Box sx={{ px: 2.5, paddingBottom: 5 }}>
            <List sx={{ pt: 0 }} className="sidebarNav">
                {Menus.map((item) => {
                    if (role === Role.employee.value && !item.roles?.includes(role)) {
                        return null;
                    }
                    if (item.subheader) {
                        return <NavGroup
                            item={item}
                            key={item.subheader} />;
                    } else if (item.children) {
                        return (
                            <NavCollapse
                                menu={item}
                                pathDirect={pathDirect}
                                pathWithoutLastPart={pathWithoutLastPart}
                                level={1}
                                key={item.id}
                                onClick={() => dispatch(setSidebarCollapse())}
                            />
                        );
                    } else {
                        return (
                            <NavItem
                                item={item}
                                key={item.id}
                                pathDirect={pathDirect}
                                onClick={() => dispatch(setSidebarCollapse())} />
                        );
                    }
                })}
            </List>
        </Box>
    );
};

export default SidebarItems;