import {
    Box, CircularProgress, Stack,
    styled,
} from "@mui/material";
import {Link, Outlet, useNavigate} from "react-router-dom";
import {useEffect, useState} from "react";
import {GetItem} from "../utils/storage";
import {StorageKey} from "../constants/constants";
import {CheckInitial} from "../service/general";

const Wrapper = styled(Box)(({ theme }) => ({
    minHeight: '100vh',
    background: theme.palette.background.default,
    display: 'flex',
    alignItems: 'center',
    overflowX: 'hidden'
}));

const Background = styled(Box)(() => ({
    width: '100%',
    minHeight: '100vh',
    position: 'absolute',
    zIndex: 0
}));

export default function AuthLayout() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);

    const fetch = async () => {
        return CheckInitial().then(res => {
            if (res?.status === 200) {
                setLoading(false);
            }
        }).catch(err => {
            if (err?.response?.status === 400) {
                navigate('/install');
                setLoading(false);
            }
        })
    }

    useEffect(() => {
        fetch();
    }, []);

    if (loading) {
        return (
            <Stack direction="row" justifyContent="center" alignItems="center">
                <CircularProgress/>
            </Stack>
        )
    }

    return (
        <Wrapper>
            <Background>
                <img
                    src="/images/home-bg.svg"
                    alt="background"
                    style={{ width: '100%', objectFit: 'cover' }}/>
            </Background>
            <Box sx={{ width: '100%' }}>
                <Outlet/>
            </Box>
        </Wrapper>
    )
}