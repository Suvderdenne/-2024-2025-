import AuthLayout from "../layouts/AuthLayout";
import {
    Alert,
    Box,
    Button,
    Card,
    CardContent,
    FormLabel,
    IconButton,
    InputAdornment,
    Stack, Tab, Tabs,
    TextField
} from "@mui/material";
import {Link, useNavigate} from "react-router-dom";
import {VisibilityOffRounded, VisibilityRounded} from "@mui/icons-material";
import {useState} from "react";
import {useFormik} from "formik";
import * as Yup from "yup";
import {LoginService} from "../service/auth";
import {SetItem} from "../utils/storage";
import {Role, StorageKey} from "../constants/constants";
import AdminCredential from "../component-pages/install/AdminCredential";
import InstallSetting from "../component-pages/install/Setting";
import {InstallService} from "../service/general";

export default function Install() {
    const navigate = useNavigate();
    const tabs = ['Admin Credential', 'Company Setting'];
    const [tabActive, setTabActive] = useState(0);
    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {},
        // validationSchema: Yup.object().shape({
        //     admin: Yup.object().shape({
        //         name: Yup.string().required('Required'),
        //         email: Yup.string().email('Invalid email').required('Required'),
        //         password: Yup.string().required("Required"),
        //     }),
        //     setting: Yup.object().shape({
        //         email: Yup.string().required('Required'),
        //         name: Yup.string().required('Required'),
        //         country: Yup.string().required('Required'),
        //         phone: Yup.string().required('Required'),
        //     })
        // }),
        validateOnChange: false,
        validateOnBlur: false,
        onSubmit: values => handleSubmit(values)
    });

    const handleSubmit = async (values) => {
        return InstallService({
            ...values,
            setting: {
                ...values.setting,
                country: values.setting?.country?.code,
            }
        }).then(async res => {
            if (res.status === 200) {
                navigate('/');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        }).catch(err => {
            if (err.response?.data ) {
                const errors = err.response?.data?.data;
                setError(errors.length > 0 ? errors.join('. ') : 'Something wrong!')
            }
        });
    };

    return (
        <Card sx={{
            width: { xs: '90%', md: '60%', lg: '30%', xl: '25%' },
            margin: 'auto',
            position: 'relative',
            zIndex: 1
        }}>
            <CardContent>
                <form onSubmit={formik.handleSubmit}>
                    <Tabs
                        textColor="secondary"
                        indicatorColor="secondary"
                        onChange={(e, val) => setTabActive(val)}
                        value={tabActive}>
                        {tabs.map((e, i) => (
                            <Tab key={i} label={e} value={i}/>
                        ))}
                    </Tabs>
                    <Box paddingY={3}>
                        {tabActive === 0 && <AdminCredential formik={formik}/>}
                        {tabActive === 1 && <InstallSetting formik={formik}/>}
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
                </form>
            </CardContent>
        </Card>
    )
}