import { useNavigate, useParams } from "react-router-dom";
import { useEffect, useRef, useState } from "react";
import { useFormik } from "formik";
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
  Stack,
  TextField,
} from "@mui/material";
import { CreateAttendance, GetAttendanceById, UpdateAttendance } from "../../service/attendance";
import dayjs from "dayjs";
import { GetUsersByQuery } from "../../service/user";
import CustomDateTimePicker from "../../components/forms/Datepicker/CustomDateTimePicker";
import { useSelector } from "react-redux";
import { Role } from "../../constants/constants";

export default function AttendanceForm() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { role, profile } = useSelector((state) => state.profile);

  // Егер id бар болса – бар attendance жазбасын алу
  const { data: resData, isLoading: loading } = useSWR(
    id ? ["/api/attendance", id] : null,
    () => GetAttendanceById(id)
  );
  const { data: resUser } = useSWR("/api/user", () => GetUsersByQuery());

  const [loadingSubmit, setLoadingSubmit] = useState(false);
  const [error, setError] = useState(null);

  // Formik бастапқы мәндері, ipAddress өрісі қосылды
  const formik = useFormik({
    initialValues: {
      userId: resData?.data?.data?.userId ?? "",
      checkIn: resData?.data?.data?.checkIn ?? null,
      checkOut: resData?.data?.data?.checkOut ?? null,
      ipAddress: resData?.data?.data?.ipAddress ?? "",
    },
    validationSchema: Yup.object().shape({
      checkIn: Yup.string().required("Required"),
    }),
    validateOnChange: false,
    validateOnBlur: false,
    onSubmit: (values) => handleSubmit(values),
  });

  const mounted = useRef(false);
  useEffect(() => {
    if (!mounted.current && resData?.data?.data?._id) {
      formik.setValues(resData.data.data);
      mounted.current = true;
    }
  }, [resData?.data?.data]);

  // Егер жаңа жазба жасалып жатса, ipAddress-ті автоматты түрде алу
  useEffect(() => {
    if (!id) {
      fetch("https://api.ipify.org?format=json")
        .then((resp) => resp.json())
        .then((data) => {
          formik.setFieldValue("ipAddress", data.ip);
        })
        .catch((err) => {
          console.error("Failed to fetch IP address", err);
          formik.setFieldValue("ipAddress", "0.0.0.0");
        });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const submit = (params) => {
    delete params._id;
    params.checkIn = params.checkIn ? dayjs(params.checkIn).format() : null;
    params.checkOut = params.checkOut ? dayjs(params.checkOut).format() : null;
    if (role === Role.employee.value) params.userId = profile?.id;
    // ipAddress-ті де payload-ке қосамыз
    if (id) {
      return UpdateAttendance(id, params);
    }
    return CreateAttendance(params);
  };

  const handleSubmit = async (values) => {
    setLoadingSubmit(true);
    const res = await submit(values);
    if (res.status === 200) {
      navigate("/app/attendance");
    } else {
      setError(res.data);
    }
    setLoadingSubmit(false);
  };

  return (
    <>
      <Breadcrumb
        title={`Ирц ${id ? "Засах" : "Үүсгэх"}`}
        items={[
          { to: "/app", title: "Хяналтын самбар" },
          { to: "/app/attendance", title: "Ирц" },
          { title: `Ирц ${id ? "Засах" : "Үүсгэх"}` },
        ]}
      />
      {error && (
        <>
          <Alert severity="error">{error}</Alert>
          <Box height={20} />
        </>
      )}
      <Box sx={{ width: { xs: "100%", lg: "50%" } }}>
        <form onSubmit={formik.handleSubmit}>
          <Stack spacing={3}>
            <Card>
              <CardContent>
                <Stack spacing={3}>
                  {role === Role.admin.value ? (
                    <Grid container>
                      <Grid item xs={12} md={4} lg={3}>
                        <FormLabel>Ажилтан</FormLabel>
                      </Grid>
                      <Grid item xs={12} md={8} lg={9}>
                        <Select
                          fullWidth
                          name="userId"
                          onChange={formik.handleChange}
                          value={formik.values.userId}
                        >
                          {resUser?.data?.data?.map((e, i) => (
                            <MenuItem key={i} value={e.id}>
                              {e.name}
                            </MenuItem>
                          ))}
                        </Select>
                      </Grid>
                    </Grid>
                  ) : (
                    <Grid container>
                      <Grid item xs={12} md={4} lg={3}>
                        <FormLabel>Ажилтан</FormLabel>
                      </Grid>
                      <Grid item xs={12} md={8} lg={9}>
                        <Box sx={{ paddingY: 1 }}>{profile.name}</Box>
                      </Grid>
                    </Grid>
                  )}

                  <Grid container>
                    <Grid item xs={12} md={4} lg={3}>
                      <FormLabel>Бүртгүүлэх</FormLabel>
                    </Grid>
                    <Grid item xs={12} md={8} lg={9}>
                      <CustomDateTimePicker
                        error={Boolean(formik.errors.checkIn)}
                        onChange={(val) => formik.setFieldValue("checkIn", val)}
                        value={formik.values.checkIn}
                      />
                    </Grid>
                  </Grid>

                  <Grid container>
                    <Grid item xs={12} md={4} lg={3}>
                      <FormLabel>Гарах</FormLabel>
                    </Grid>
                    <Grid item xs={12} md={8} lg={9}>
                      <CustomDateTimePicker
                        error={Boolean(formik.errors.checkOut)}
                        onChange={(val) => formik.setFieldValue("checkOut", val)}
                        value={formik.values.checkOut}
                      />
                    </Grid>
                  </Grid>

                  {/* IP Address өрісі */}
                  <Grid container>
                    <Grid item xs={12} md={4} lg={3}>
                      <FormLabel>IP хаяг</FormLabel>
                    </Grid>
                    <Grid item xs={12} md={8} lg={9}>
                      <TextField
                        fullWidth
                        name="ipAddress"
                        value={formik.values.ipAddress}
                        onChange={formik.handleChange}
                        disabled
                      />
                    </Grid>
                  </Grid>
                </Stack>
              </CardContent>
            </Card>
            {/* Submit батырмасы */}
            <Stack direction="row" justifyContent="end">
              <Button
                disabled={loadingSubmit}
                color="primary"
                variant="contained"
                type="submit"
              >
                Хадгалах
              </Button>
            </Stack>
          </Stack>
        </form>
      </Box>
    </>
  );
}
