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
import {CreateExpense, GetExpenseById, UpdateExpense} from "../../service/expense";
import CustomDatePicker from "../../components/forms/Datepicker/CustomDatePicker";
import dayjs from "dayjs";
import {GetUsersByQuery} from "../../service/user";
import CustomTimePicker from "../../components/forms/Datepicker/CustomTimePicker";
import CustomDateTimePicker from "../../components/forms/Datepicker/CustomDateTimePicker";
import {ExpenseStatus} from "../../constants/constants";

export default function ExpenseForm() {
    const { id } = useParams();
    const navigate = useNavigate();

    const { data: resData, isLoading: loading} = useSWR(id ? ['/api/expense', id] : null,
        () => GetExpenseById(id));
    const { data: resUser, isLoading: loadingUser} = useSWR('/api/user', () => GetUsersByQuery());

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            title: resData?.data?.data?.userId ?? '',
            description: resData?.data?.data?.userId ?? '',
            date: resData?.data?.data?.date ?? null,
            amount: resData?.data?.data?.amount ?? null,
            status: resData?.data?.data?.status ?? null,
        },
        validationSchema: Yup.object().shape({
            title: Yup.string().required('Required'),
            amount: Yup.string().required('Required'),
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
            return UpdateExpense(id, params);
        }

        return CreateExpense(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/expense');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Зарлага ${id ? 'Засах' : 'Үүсгэх'}`}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/expense', title: 'Зарлага' },
                    { title: `Зарлага ${id ? 'Засах' : 'Үүсгэх'}` },
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
                                            <FormLabel>Дүн</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="amount"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.amount)}
                                                helperText={formik.errors.amount}
                                                value={formik.values.amount}
                                                type="number"/>
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Он сар өдөр</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDatePicker
                                                error={Boolean(formik.errors.date)}
                                                onChange={(val) => formik.setFieldValue('date', val)}
                                                value={formik.values.start}
                                            />
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Status</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="status"
                                                onChange={formik.handleChange}
                                                value={formik.values.userId}>
                                                {Object.keys(ExpenseStatus)?.map(key => (
                                                    <MenuItem key={key} value={key}>
                                                        {ExpenseStatus[key].name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
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