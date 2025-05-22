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
    Stack, TextField,
} from "@mui/material";
import {CreateDepartment, GetDepartmentById, UpdateDepartment} from "../../service/department";
import dayjs from "dayjs";

export default function DepartmentForm() {
    const { id } = useParams();
    const navigate = useNavigate();

    const { data: resData} = useSWR(id ? ['/api/department', id] : null,
        () => GetDepartmentById(id));

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            name: resData?.data?.data?.name ?? '',
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
            return UpdateDepartment(id, params);
        }

        return CreateDepartment(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/department');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`Хэлтэс ${id ? 'засах' : 'үүсгэх'} `}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/user', title: 'Хэлтэс' },
                    { title: `Хэлтэс ${id ? 'засах' : 'үүсгэх'} ` },
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
                                            <FormLabel>Хэлтстийн нэр</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="name"
                                                onChange={formik.handleChange}
                                                value={formik.values.name}/>
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