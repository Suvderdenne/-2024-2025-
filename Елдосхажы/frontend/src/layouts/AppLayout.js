import {Box, CircularProgress, Stack, styled, Typography} from "@mui/material";
import {Outlet, useNavigate} from "react-router-dom";
import AppNavbar from "./components/navbar/AppNavbar";
import AppSidebar from "./components/sidebar/AppSidebar";
import {useEffect, useState} from "react";
import {GetItem} from "../utils/storage";
import {StorageKey} from "../constants/constants";
import {useDispatch} from "../store";
import {setProfile} from "../store/slices/ProfileSlice";

const MainWrapper = styled(Box)(({ theme }) => ({
    display: "flex",
    minHeight: "100vh",
    width: "100%",
    background: theme.palette.background.default
}));

const PageWrapper = styled(Box)(() => ({
    display: "flex",
    flexGrow: 1,
    paddingLeft: 20,
    paddingRight: 20,
    paddingBottom: "60px",
    flexDirection: "column",
    zIndex: 1,
    width: "100%",
    backgroundColor: "transparent",
}));

export default function AppLayout() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const dispatch = useDispatch();

    const fetch = async () => {
        const isAuthed = await GetItem(StorageKey.TOKEN);
        if (isAuthed) {
            const user = await GetItem(StorageKey.USER);
            dispatch(setProfile(user));
            setLoading(false);
        } else if (!isAuthed) {
            navigate('/');
        }
    }

    useEffect(() => {
        setTimeout(() => {
            fetch();
        }, 1000)
    }, []);

    if (loading) {
        return (
            <Stack direction="row" justifyContent="center" alignItems="center" marginTop={4}>
                <CircularProgress/>
            </Stack>
        )
    }

    return (
        <MainWrapper>
            <AppSidebar/>
            <PageWrapper>
                <AppNavbar/>
                <Outlet/>
            </PageWrapper>
        </MainWrapper>
    )
}