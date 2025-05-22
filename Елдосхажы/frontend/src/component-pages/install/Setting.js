import {Box, FormLabel, IconButton, InputAdornment, Stack, TextField} from "@mui/material";
import {VisibilityOffRounded, VisibilityRounded} from "@mui/icons-material";
import CountrySelect from "../../components/forms/CountrySelect";
import PhoneInput from "../../components/forms/PhoneInput";

export default function InstallSetting({ formik }) {
    return (
        <Stack spacing={2}>
            <Box>
                <FormLabel>Company Name</FormLabel>
                <TextField
                    fullWidth
                    name="setting.name"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.setting?.name)}
                    helperText={formik.errors.setting?.name}
                    value={formik.values.name}/>
            </Box>
            <Box>
                <FormLabel>Company Email</FormLabel>
                <TextField
                    fullWidth
                    name="setting.email"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.setting?.email)}
                    helperText={formik.errors.setting?.email}
                    value={formik.values.setting?.email}/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>Address</FormLabel>
                <TextField
                    fullWidth
                    name="setting.address"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.setting?.address)}
                    value={formik.values.setting?.address}
                    helperText={formik.errors.setting?.address}/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>City</FormLabel>
                <TextField
                    fullWidth
                    name="setting.city"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.setting?.city)}
                    value={formik.values.setting?.city}
                    helperText={formik.errors.setting?.city}/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>Country</FormLabel>
                <CountrySelect
                    error={Boolean(formik.errors.setting?.country)}
                    helperText={formik.errors.setting?.country}
                    onChange={(val) => formik.setFieldValue('setting.country', val)}
                    value={formik.values.setting?.country}/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>Phone Number</FormLabel>
                <PhoneInput
                    error={Boolean(formik.errors.setting?.phone)}
                    helperText={formik.errors.setting?.phone}
                    onChange={(val) => formik.setFieldValue('setting.phone', val)}
                    value={formik.values.setting?.phone}/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>Default Leave Limit Per Year</FormLabel>
                <TextField
                    fullWidth
                    name="setting.leaveLimit"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.setting?.leaveLimit)}
                    helperText={formik.errors.setting?.leaveLimit}
                    value={formik.values.setting?.leaveLimit}/>
            </Box>
        </Stack>
    )
}