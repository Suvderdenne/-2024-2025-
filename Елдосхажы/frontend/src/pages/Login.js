import {
    Alert,
    Box,
    Button,
    Card,
    CardContent,
    FormLabel,
    IconButton,
    InputAdornment,
    Stack,
    styled,
    TextField
} from "@mui/material";
import {Link, useNavigate} from "react-router-dom";
import {useState} from "react";
import {useFormik} from "formik";
import * as Yup from "yup";
import {LoginService} from "../service/auth";
import {SetItem} from "../utils/storage";
import {StorageKey} from "../constants/constants";
import {VisibilityOffRounded, VisibilityRounded} from "@mui/icons-material";
import AuthLayout from "../layouts/AuthLayout";


export default function Login() {
    const navigate = useNavigate();
    const [showPassword, setShowPassword] = useState(false);
    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: { email: '', password: '' },
        validationSchema: Yup.object().shape({
            email: Yup.string().email('Invalid email').required('Required'),
            password: Yup.string().required("Please enter a password"),
        }),
        validateOnChange: false,
        validateOnBlur: false,
        onSubmit: values => handleSubmit(values)
    });
    // console.log(formik.values)
    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return LoginService(values).then(async res => {
            if (res.status === 200) {
                const { id, email, fullname, role, token } = res?.data?.data;
                await SetItem(StorageKey.TOKEN, token);
                await SetItem(StorageKey.USER, JSON.stringify({id, email, fullname, role}));
                navigate('/app');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        }).catch(err => {
            if (err.response?.data ) {
                setError(err.response?.data?.data ?? 'Something wrong!')
                setLoadingSubmit(false);
            }
        });
    };

    return (
        <Box>
            <Card sx={{
                width: { xs: '90%', md: '60%', lg: '30%', xl: '25%' },
                margin: 'auto',
                position: 'relative',
                zIndex: 1
            }}>
                <CardContent>
                    <form onSubmit={formik.handleSubmit}>
                        <Stack justifyContent="center" alignItems="center" spacing={3} sx={{ minHeight: '100%' }}>
                            <Link to="/">
                                <img src="/images/logo/logo.svg" alt="logo" style={{ width: 200, height: 80 }}/>
                            </Link>
                            {error && (
                                <>
                                    <Alert severity="error">{error}</Alert>
                                </>
                            )}
                            <Box sx={{ width: '100%' }}>
                                <FormLabel>Email Address</FormLabel>
                                <TextField
                                    fullWidth
                                    // name="email"
                                    onChange={(e) => formik.setFieldValue('email', e.target.value)}
                                    // error={Boolean(formik.errors.email)}
                                    // helperText={formik.errors.email}
                                    // value={formik.values.email}
                                    type="email"/>
                            </Box>
                            <Box sx={{ width: '100%' }}>
                                <FormLabel>Password</FormLabel>
                                <TextField
                                    fullWidth
                                    name="password"
                                    error={Boolean(formik.errors.password)}
                                    helperText={formik.errors.password}
                                    type={showPassword ? 'text' : 'password'}
                                    onChange={formik.handleChange}
                                    InputProps={{
                                        endAdornment: <InputAdornment position="end">
                                            <IconButton onClick={() => setShowPassword(!showPassword)}>
                                                {showPassword ? <VisibilityRounded fontSize="small"/> : <VisibilityOffRounded fontSize="small"/>}
                                            </IconButton>
                                        </InputAdornment>
                                    }}/>
                            </Box>
                            <Button
                                fullWidth
                                disableElevation
                                disabled={loadingSubmit}
                                color="primary"
                                variant="contained"
                                type="submit">
                                Login
                            </Button>
                        </Stack>
                    </form>
                </CardContent>
            </Card>
        </Box>
    )
}