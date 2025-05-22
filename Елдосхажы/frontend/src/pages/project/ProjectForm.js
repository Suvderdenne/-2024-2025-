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
import {CreateProject, GetProjectById, UpdateProject} from "../../service/project";
import dayjs from "dayjs";

export default function ProjectForm() {
    const { id } = useParams();
    const navigate = useNavigate();

    const { data: resData, isLoading: loading} = useSWR(id ? ['/api/project', id] : null,
        () => GetProjectById(id));

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            name: resData?.data?.data?.name ?? '',
            description: resData?.data?.data?.description ?? '',
            progress: resData?.data?.data?.progress ?? 0,
            status: resData?.data?.data?.status ?? false,
        },
        validationSchema: Yup.object().shape({
            name: Yup.string().required('Required'),
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

        if (id) {
            return UpdateProject(id, params);
        }

        return CreateProject(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/project');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Төсөл ${id ? 'засах' : 'үүсгэх'}`}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/project', title: 'Төсөл' },
                    { title: `Төсөл ${id ? 'засах' : 'үүсгэх'}` },
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
                                            <FormLabel>Төслийн нэр</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="name"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.name)}
                                                helperText={formik.errors.name}
                                                value={formik.values.name}/>
                                        </Grid>
                                    </Grid>
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
                                                <MenuItem value="true">Идэвхтэй</MenuItem>
                                                <MenuItem value="false">Дууссан</MenuItem>
                                            </Select>
                                        </Grid>
                                    </Grid>
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Project Progress</FormLabel>
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