import {useNavigate, useParams} from "react-router-dom";
import {useEffect, useRef, useState} from "react";
import {useFormik} from "formik";
import useSWR from "swr";
import * as Yup from "yup";
import Breadcrumb from "../../components/Breadcrumb";
import {Alert, Box, Button, Card, CardContent, FormLabel, Grid, Stack, TextField} from "@mui/material";
import {CreateAnnouncement, GetAnnouncementById, UpdateAnnouncement} from "../../service/announcement";
import CustomDatePicker from "../../components/forms/Datepicker/CustomDatePicker";
import CustomSwitch from "../../components/forms/CustomSwitch";
import moment from "moment";
import dayjs from "dayjs";

export default function AnnouncementForm() {
    const { id } = useParams();
    const navigate = useNavigate();

    const { data: resData, isLoading: loading, mutate } = useSWR(id ? ['/api/announcement', id] : null, () => GetAnnouncementById(id));

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            title: resData?.data?.data?.title ?? '',
            startDate: resData?.data?.data?.startDate ?? null,
            endDate: resData?.data?.data?.endDate ?? null,
            status: resData?.data?.data?.status ?? '',
            content: resData?.data?.data?.content ?? '',
        },
        validationSchema: Yup.object().shape({
            title: Yup.string().required('Required'),
            startDate: Yup.string().required('Required'),
            endDate: Yup.string().required('Required'),
            content: Yup.string().required('Required'),
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
        params.startDate = dayjs(params.startDate).startOf('day').format();
        params.endDate = dayjs(params.endDate).endOf('day').format();

        if (id) {
            return UpdateAnnouncement(id, params);
        }

        return CreateAnnouncement(params);
    }

    const handleSubmit = async (values) => {
        // setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/announcement');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Зарлал ${id ? 'засах' : 'үүсгэх'}`}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/user', title: 'Зарлал' },
                    { title: `Зарлал ${id ? 'засах' : 'үүсгэх'}` },
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
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Эхлэх огноо</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDatePicker
                                                error={Boolean(formik.errors.startDate)}
                                                onChange={(val) => formik.setFieldValue('startDate', val)}
                                                value={formik.values.startDate}
                                            />
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Дуусах огноо</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDatePicker
                                                minDate={formik.values.startDate || new Date()}
                                                error={Boolean(formik.errors.endDate)}
                                                onChange={(val) => formik.setFieldValue('endDate', val)}
                                                value={formik.values.endDate}/>
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Төлөв</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomSwitch
                                                checked={formik.values.status}
                                                onChange={(e) => formik.setFieldValue('status', e.target.checked)}/>
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Тайлбар</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                multiline
                                                rows={3}
                                                name="content"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.content)}
                                                helperText={formik.errors.content}
                                                value={formik.values.content}/>
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