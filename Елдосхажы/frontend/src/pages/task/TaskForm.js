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
    Grid, InputAdornment,
    MenuItem,
    Select,
    Stack, TextField,
} from "@mui/material";
import {CreateTask, GetTaskById, UpdateTask} from "../../service/task";
import dayjs from "dayjs";
import {GetUsersByQuery} from "../../service/user";
import CustomDateTimePicker from "../../components/forms/Datepicker/CustomDateTimePicker";
import {GetProjectsByQuery} from "../../service/project";
import {useSelector} from "react-redux";
import {Role} from "../../constants/constants";

export default function TaskForm() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { role } = useSelector(state => state.profile);

    const { data: resData, isLoading: loading} = useSWR(id ? ['/api/task', id] : null,
        () => GetTaskById(id));
    const { data: resUser, isLoading: loadingUser} = useSWR('/api/user', () => GetUsersByQuery());
    const { data: resProject} = useSWR('/api/project',
        () => GetProjectsByQuery({}), {
            revalidateOnFocus: false,
            revalidateOnReconnect: false,
        });

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            projectId: resData?.data?.data?.projectId ?? '',
            userId: resData?.data?.data?.userId ?? '',
            title: resData?.data?.data?.title ?? '',
            description: resData?.data?.data?.description ?? '',
            dueDate: resData?.data?.data?.dueDate ?? null,
            progress: resData?.data?.data?.progress ?? 0,
            status: resData?.data?.data?.status ?? false,
        },
        validationSchema: Yup.object().shape({
            title: Yup.string().required('Required'),
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
        if (params.dueDate) params.dueDate = dayjs(params.dueDate).format();

        if (id) {
            return UpdateTask(id, params);
        }

        return CreateTask(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/task');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Даалгавар ${id ? 'Өөрчлүүлэх' : 'Өгөх'}`}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/task', title: 'Даалгавар' },
                    { title: `Даалгавар ${id ? 'Өөрчлүүлэх' : 'Өгөх'}` },
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
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Даалгавар</FormLabel>
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
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Төсөл</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="projectId"
                                                onChange={formik.handleChange}
                                                value={formik.values.projectId}>
                                                {resProject?.data?.data?.map((e, i) => (
                                                    <MenuItem key={i} value={e.id}>
                                                        {e.name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </Grid>
                                    </Grid>
                                    {role === Role.admin.value && (
                                        <Grid container alignItems="center">
                                            <Grid item xs={12} md={4} lg={3}>
                                                <FormLabel>Assigned To</FormLabel>
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
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Төлөв</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="status"
                                                onChange={formik.handleChange}
                                                value={formik.values.status}>
                                                <MenuItem value={true}>Идэвхтэй</MenuItem>
                                                <MenuItem value={false}>Дууссан</MenuItem>
                                            </Select>
                                        </Grid>
                                    </Grid>
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Эцсийн хугацаа</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDateTimePicker
                                                error={Boolean(formik.errors.dueDate)}
                                                onChange={(val) => formik.setFieldValue('dueDate', val)}
                                                value={formik.values.dueDate}
                                            />
                                        </Grid>
                                    </Grid>
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Даалгаврын явц</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="progress"
                                                InputProps={{
                                                    endAdornment: <InputAdornment position="end">%</InputAdornment>
                                                }}
                                                onChange={formik.handleChange}
                                                value={formik.values.progress}/>
                                        </Grid>
                                    </Grid>
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