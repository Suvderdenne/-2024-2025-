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
    Grid, MenuItem, Select,
    Stack, TextField,
} from "@mui/material";
import {CreateDesignation, GetDesignationById, UpdateDesignation} from "../../service/designation";
import dayjs from "dayjs";
import {GetDepartmentsByQuery} from "../../service/department";

export default function DesignationForm() {
    const { id } = useParams();
    const navigate = useNavigate();

    const { data: resData} = useSWR(id ? ['/api/designation', id] : null,
        () => GetDesignationById(id), {revalidateOnFocus: false, revalidateOnReconnect: false});
    const { data: resDepartment, isLoading: loading, mutate } = useSWR('/api/department',
        () => GetDepartmentsByQuery({}), {revalidateOnFocus: false, revalidateOnReconnect: false});

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            departmentId: resData?.data?.data?.departmentId ?? '',
            name: resData?.data?.data?.name ?? '',
            description: resData?.data?.data?.description ?? '',
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

        if (id) {
            return UpdateDesignation(id, params);
        }

        return CreateDesignation(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/designation');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Тэмдэглэлүүд ${id ? 'засах' : 'үүсгэх'}`}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/designation', title: 'Тэмдэглэл' },
                    { title: `Тэмдэглэл ${id ? 'засах' : 'үүсгэх'}`},
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
                                    {/* <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Хэлтэс</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="departmentId"
                                                onChange={formik.handleChange}
                                                value={formik.values.departmentId}>
                                                {resDepartment?.data?.data?.map((e, i) => (
                                                    <MenuItem key={i} value={e.id}>
                                                        {e.name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </Grid>
                                    </Grid> */}
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Тэмдэглэлийн нэр</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="name"
                                                onChange={formik.handleChange}
                                                value={formik.values.name}/>
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Тодорхойлолт</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                multiline
                                                rows={4}
                                                name="description"
                                                onChange={formik.handleChange}
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