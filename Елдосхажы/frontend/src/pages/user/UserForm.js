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
    Grid, IconButton, InputAdornment,
    MenuItem,
    Select,
    Stack, TextField,
} from "@mui/material";
import {CreateUser, UpdateUser} from "../../service/user";
import CustomDatePicker from "../../components/forms/Datepicker/CustomDatePicker";
import dayjs from "dayjs";
import {GetUserById} from "../../service/user";
// import {GetDepartmentsByQuery} from "../../service/department";
// import {GetDesignationsByQuery} from "../../service/designation";
import CustomSwitch from "../../components/forms/CustomSwitch";
import {DefaultSwrOptions, Role} from "../../constants/constants";
import {VisibilityOffRounded, VisibilityRounded} from "@mui/icons-material";

export default function UserForm(builder) {
    const { id } = useParams();
    const navigate = useNavigate();

    const { data: resData, isLoading: loading} = useSWR(id ? ['/api/user', id] : null, () => GetUserById(id));
    // const { data: resDepartment, isLoading: loadingDepartment} = useSWR('/api/department',
    //     () => GetDepartmentsByQuery(), DefaultSwrOptions);
    // const { data: resDesignation, isLoading: loadingDesignation} = useSWR('/api/designation',
    //     () => GetDesignationsByQuery(), DefaultSwrOptions);

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);
    const [showPassword, setShowPassword] = useState(false);

    const formik = useFormik({
        initialValues: {
            email: resData?.data?.data?.email ?? '',
            password: resData?.data?.data?.password ?? '',
            name: resData?.data?.data?.name ?? '',
            phone: resData?.data?.data?.phone ?? '',
            avatar: resData?.data?.data?.avatar ?? '',
            country: resData?.data?.data?.country ?? '',
            city: resData?.data?.data?.city ?? '',
            address: resData?.data?.data?.address ?? '',
            gender: resData?.data?.data?.gender ?? '',
            birthday: resData?.data?.data?.birthday ?? '',
            description: resData?.data?.data?.description ?? '',
            // departmentId: resData?.data?.data?.departmentId ?? '',
            // designationId: resData?.data?.data?.designationId ?? '',
            role: resData?.data?.data?.role ?? '',
            status: resData?.data?.data?.status ?? true,
        },
        validationSchema: Yup.object().shape({
            email: Yup.string().required('Required'),
            name: Yup.string().required('Required'),
            role: Yup.string().required('Required'),
            password: Yup.string().when([], {
                is: () => !id,
                then: () => Yup.string().required('Required'),
                otherwise: () => Yup.string(),
            }),
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
        params.birthday = dayjs(params.birthday).format();

        if (id) {
            return UpdateUser(id, params);
        }

        return CreateUser(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
    
        try {
            const res = await submit(values);
            if (res.status === 200) {
                navigate('/app/user');
            } else {
                setError(res.data);
            }
        } catch (err) {
            setError('Server error');
        } finally {
            setLoadingSubmit(false);
        }
    };
    console.log(formik.errors)
    return (
        <>
            <Breadcrumb
                title={`Хэрэглэгч ${id ? 'засах' : 'үүсгэх'} `}
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { to: '/app/user', title: 'Хэрэглэгч' },
                    { title: `Хэрэглэгч ${id ? 'засах' : 'үүсгэх'} ` },
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
                                            <FormLabel>Нэр<span style={{ color: 'red' }}>*</span></FormLabel>
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
                                            <FormLabel>Имейл хаяг<span style={{ color: 'red' }}>*</span></FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <TextField
                                                fullWidth
                                                name="email"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.email)}
                                                helperText={formik.errors.email}
                                                value={formik.values.email}/>
                                        </Grid>
                                    </Grid>
                                    <Grid container alignItems="center">
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Нууц үг<span style={{ color: 'red' }}>*</span></FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
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
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Албан тушаал</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="role"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.role)}
                                                helperText={formik.errors.role}
                                                value={formik.values.role}>
                                                {Object.keys(Role).map(key => (
                                                    <MenuItem key={key} value={key}>
                                                        {Role[key].name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </Grid>
                                    </Grid>
                                    {/* <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Хэлтэс</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="departmentId"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.departmentId)}
                                                helperText={formik.errors.departmentId}
                                                value={formik.values.departmentId}>
                                                {resDepartment?.data?.data?.map((e, i) => (
                                                    <MenuItem key={i} value={e.id}>
                                                        {e.name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </Grid> */}
                                    {/* </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Тэмдэглэл</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <Select
                                                fullWidth
                                                name="designationId"
                                                onChange={formik.handleChange}
                                                error={Boolean(formik.errors.designationId)}
                                                helperText={formik.errors.designationId}
                                                value={formik.values.designationId}>
                                                {resDesignation?.data?.data?.map((e, i) => (
                                                    <MenuItem key={i} value={e.id}>
                                                        {e.name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </Grid>
                                    </Grid> */}
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Төрсөн өдөр</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDatePicker
                                                maxDate={dayjs().subtract(16, 'years')}
                                                error={Boolean(formik.errors.birthday)}
                                                onChange={(val) => formik.setFieldValue('birthday', val)}
                                                value={formik.values.birthday}
                                            />
                                        </Grid>
                                    </Grid>
                                    {/* <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Status</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomSwitch
                                                checked={formik.values.status}
                                                onChange={(e) => formik.setFieldValue('status', e.target.checked)}/>
                                        </Grid>
                                    </Grid> */}
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