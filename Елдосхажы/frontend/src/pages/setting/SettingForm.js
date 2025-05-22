import InstallSetting from "../../component-pages/install/Setting";
import {useEffect, useRef, useState} from "react";
import {useFormik} from "formik";
import * as Yup from "yup";
import {DefaultSwrOptions, Role} from "../../constants/constants";
import {InstallService} from "../../service/general";
import useSWR from "swr";
import {GetSetting, UpdateSetting} from "../../service/setting";
import Breadcrumb from "../../components/Breadcrumb";
import {
    Alert,
    Box, Button,
    Card,
    CardContent,
    FormLabel,
    Grid,
    InputAdornment,
    MenuItem,
    Select,
    Stack,
    TextField
} from "@mui/material";
import CustomDateTimePicker from "../../components/forms/Datepicker/CustomDateTimePicker";
import CountrySelect from "../../components/forms/CountrySelect";
import PhoneInput from "../../components/forms/PhoneInput";

export default function SettingForm() {
    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(null);

    const { data: resData } = useSWR('/api/setting', () => GetSetting(), DefaultSwrOptions);

    const formik = useFormik({
        initialValues: {
            email: resData?.data?.data?.email ?? '',
            name: resData?.data?.data?.name ?? '',
            address: resData?.data?.data?.address ?? '',
            city: resData?.data?.data?.city ?? '',
            country: resData?.data?.data?.country ?? '',
            phone: resData?.data?.data?.phone ?? '',
        },
        validateOnChange: false,
        validateOnBlur: false,
        onSubmit: values => handleSubmit(values)
    });

    const mounted = useRef(false);
    useEffect(() => {
        if (!mounted.current && resData?.data?.data?._id) {
            formik.setValues(resData?.data?.data);
            mounted.current = true;
        }
    }, [resData?.data?.data]);

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return UpdateSetting(values).then(res => {
            if (res.status === 200) {
                setSuccess('Successfully Updated Data');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title="Хувийн мэдээлэл"
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { title: "Хувийн мэдээлэл" },
                ]}/>
            <Box sx={{ width: { xs: '100%', lg: '50%' }}}>
                <form onSubmit={formik.handleSubmit}>
                    <Stack spacing={3}>
                        <Card>
                            <CardContent>
                                {error && (
                                    <>
                                        <Alert severity="error">{error}</Alert>
                                        <Box height={20}/>
                                    </>
                                )}
                                {success && (
                                    <>
                                        <Alert severity="success">{success}</Alert>
                                        <Box height={20}/>
                                    </>
                                )}
                                <Stack spacing={2}>
                                    <Box>
                                        <FormLabel>Компаний нэр</FormLabel>
                                        <TextField
                                            fullWidth
                                            name="name"
                                            onChange={formik.handleChange}
                                            error={Boolean(formik.errors.name)}
                                            helperText={formik.errors.name}
                                            value={formik.values.name}/>
                                    </Box>
                                    <Box>
                                        <FormLabel>Имейл хаяг</FormLabel>
                                        <TextField
                                            fullWidth
                                            name="email"
                                            onChange={formik.handleChange}
                                            error={Boolean(formik.errors.email)}
                                            helperText={formik.errors.email}
                                            value={formik.values.email}/>
                                    </Box>
                                    <Box sx={{ width: '100%' }}>
                                        <FormLabel>Оршин суугаа хаяг</FormLabel>
                                        <TextField
                                            fullWidth
                                            name="address"
                                            onChange={formik.handleChange}
                                            error={Boolean(formik.errors.address)}
                                            helperText={formik.errors.address}
                                            value={formik.values.address}/>
                                    </Box>
                                    <Box sx={{ width: '100%' }}>
                                        <FormLabel>Хот</FormLabel>
                                        <TextField
                                            fullWidth
                                            name="city"
                                            onChange={formik.handleChange}
                                            error={Boolean(formik.errors.city)}
                                            helperText={formik.errors.city}
                                            value={formik.values.city}/>
                                    </Box>
                                    <Box sx={{ width: '100%' }}>
                                        <FormLabel>Улс</FormLabel>
                                        <CountrySelect
                                            error={Boolean(formik.errors.country)}
                                            helperText={formik.errors.country}
                                            onChange={(val) => formik.setFieldValue('country', val)}
                                            defaultValue={resData?.data?.data?.country}
                                            value={formik.values.country}
                                        />
                                    </Box>
                                    <Box sx={{ width: '100%' }}>
                                        <FormLabel>Утасны дугаар</FormLabel>
                                        <PhoneInput
                                            error={Boolean(formik.errors.phone)}
                                            helperText={formik.errors.phone}
                                            onChange={(val) => formik.setFieldValue('phone', val)}
                                            value={formik.values.phone}/>
                                    </Box>
                                </Stack>
                            </CardContent>
                        </Card>
                        <Stack direction="row" justifyContent="end">
                            <Button
                                disabled={loadingSubmit}
                                color="primary"
                                variant="contained"
                                type="submit">
                                Submit
                            </Button>
                        </Stack>
                    </Stack>
                </form>
            </Box>
        </>
    )
}