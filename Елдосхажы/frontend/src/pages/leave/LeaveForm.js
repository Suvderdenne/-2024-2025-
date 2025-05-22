import {useNavigate, useParams} from "react-router-dom";
import {useEffect, useRef, useState} from "react";
import {useFormik} from "formik";
import useSWR from "swr";
import * as Yup from "yup";
import Breadcrumb from "../../components/Breadcrumb";
import {
    Alert,
    Box,
    Button,
    Card,
    CardContent,
    FormLabel,
    Grid,
    MenuItem,
    Select,
    Stack, TextField,
} from "@mui/material";
import {CreateLeave, GetLeaveById, UpdateLeave} from "../../service/leave";
import CustomDatePicker from "../../components/forms/Datepicker/CustomDatePicker";
import dayjs from "dayjs";
import {GetUsersByQuery} from "../../service/user";
import CustomTimePicker from "../../components/forms/Datepicker/CustomTimePicker";
import CustomDateTimePicker from "../../components/forms/Datepicker/CustomDateTimePicker";
import {LeaveStatus, Role} from "../../constants/constants";
import {useSelector} from "react-redux";

export default function LeaveForm() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { role, profile } = useSelector(state => state.profile);

    const { data: resData, isLoading: loading} = useSWR(id ? ['/api/leave', id] : null,
        () => GetLeaveById(id));
    const { data: resUser, isLoading: loadingUser} = useSWR('/api/user', () => GetUsersByQuery());

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            userId: resData?.data?.data?.userId ?? '',
            title: resData?.data?.data?.userId ?? '',
            description: resData?.data?.data?.userId ?? '',
            start: resData?.data?.data?.start ?? null,
            end: resData?.data?.data?.end ?? null,
            type: resData?.data?.data?.type ?? null,
            status: resData?.data?.data?.status ?? LeaveStatus.pending.value,
        },
        validationSchema: Yup.object().shape({
            start: Yup.string().required('Required'),
            end: Yup.string().required('Required'),
        }),
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

    const submit = (params) => {
        delete params._id;
        params.start = dayjs(params.start).format();
        if (params.end) params.end = dayjs(params.end).format();
        if (role === Role.employee.value) params.userId = profile?.id;

        if (id) {
            return UpdateLeave(id, params);
        }

        return CreateLeave(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/leave');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Чөлөө ${id ? 'засах' : 'авах'} `}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/leave', title: 'Чөлөө' },
                    { title: `Чөлөө ${id ? 'засах' : 'авах'} ` },
                ]}/>
            {error && (
                <>
                    <Alert severity="error">{error}</Alert>
                    <Box height={20}/>
                </>
            )}
            <Box sx={{ width: { xs: '100%', lg: '50%' }}}>
                <form onSubmit={formik.handleSubmit}>
                    <Stack spacing={3}>
                        <Card>
                            <CardContent>
                                <Stack spacing={3}>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Сэдэв</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="title"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.title)}
                                                helperText={formik.errors.title}
                                                value={formik.values.title}/>
                                        </Grid>
                                    </Grid>
                                    {role === Role.admin.value && (
                                        <Grid container>
                                            <Grid item xs={12} md={4} lg={3}>
                                                <FormLabel>Ажилтан</FormLabel>
                                            </Grid>
                                            <Grid item xs={12} md={8} lg={9}>
                                                <Select
                                                    fullWidth
                                                    name="userId"
                                                    onChange={formik.handleChange}
                                                    value={formik.values.userId}>
                                                    {resUser?.data?.data?.map((e, i) => (
                                                        <MenuItem key={i} value={e.id}>
                                                            {e.name}
                                                        </MenuItem>
                                                    ))}
                                                </Select>
                                            </Grid>
                                        </Grid>
                                    )}
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Эхлэх огноо</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDateTimePicker
                                                error={Boolean(formik.errors.start)}
                                                onChange={(val) => formik.setFieldValue('start', val)}
                                                value={formik.values.start}
                                            />
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Дуусах огноо</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDateTimePicker
                                                error={Boolean(formik.errors.end)}
                                                onChange={(val) => formik.setFieldValue('end', val)}
                                                value={formik.values.end}/>
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Чөлөөний төрөл</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="type"
                                                onChange={formik.handleChange}
                                                value={formik.values.type}>
                                                <MenuItem value="Uvchtei">Өвчтэй</MenuItem>
                                                <MenuItem value="Ar-geriin-asuudal">Ар гэрийн асуудал</MenuItem>
                                                <MenuItem value="Amralt">Амралт</MenuItem>
                                            </Select>
                                        </Grid>
                                    </Grid>
                                    {role === Role.admin.value && (
                                        <Grid container>
                                            <Grid item xs={12} md={4} lg={3}>
                                                <FormLabel>Албан тушаал</FormLabel>
                                            </Grid>
                                            <Grid item xs={12} md={8} lg={9}>
                                                <Select
                                                    fullWidth
                                                    name="status"
                                                    onChange={formik.handleChange}
                                                    value={formik.values.status}>
                                                    {Object.keys(LeaveStatus)?.map(key => (
                                                        <MenuItem key={key} value={key}>
                                                            {LeaveStatus[key].name}
                                                        </MenuItem>
                                                    ))}
                                                </Select>
                                            </Grid>
                                        </Grid>
                                    )}
                                    <Grid container>
                                        <Grid item xs={12} md={12} lg={12}>
                                            <FormLabel>Тайлбар</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={12} lg={12}>
                                            <TextField
                                                fullWidth
                                                multiline
                                                rows={5}
                                                name="description"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.description)}
                                                helperText={formik.errors.description}
                                                value={formik.values.description}/>
                                        </Grid>
                                    </Grid>
                                </Stack>
                            </CardContent>
                        </Card>
                        <Stack direction="row" justifyContent="end">
                            <Button
                                disabled={loadingSubmit}
                                color="primary"
                                variant="contained"
                                type="submit">
                                Хадгалах
                            </Button>
                        </Stack>
                    </Stack>
                </form>
            </Box>
        </>
    )
}