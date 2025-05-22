import {Box, FormLabel, Grid, IconButton, InputAdornment, Stack, TextField} from "@mui/material";
import {VisibilityOffRounded, VisibilityRounded} from "@mui/icons-material";
import {useState} from "react";

export default function AdminCredential({ formik }) {
    const [showPassword, setShowPassword] = useState(false);

    return (
        <Stack spacing={2}>
            <Box>
                <FormLabel>Name</FormLabel>
                <TextField
                    fullWidth
                    name="admin.name"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.admin?.name)}
                    helperText={formik.errors.admin?.name}
                    value={formik.values.admin?.name}/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>Email Address</FormLabel>
                <TextField
                    fullWidth
                    name="admin.email"
                    onChange={formik.handleChange}
                    error={Boolean(formik.errors.admin?.email)}
                    helperText={formik.errors.admin?.email}
                    value={formik.values.admin?.email}
                    type="email"/>
            </Box>
            <Box sx={{ width: '100%' }}>
                <FormLabel>Password</FormLabel>
                <TextField
                    fullWidth
                    name="admin.password"
                    error={Boolean(formik.errors.admin?.password)}
                    helperText={formik.errors.admin?.password}
                    value={formik.values.admin?.password}
                    type={showPassword ? 'text' : 'password'}
                    onChange={formik.handleChange}
                    InputProps={{
                        endAdornment: <InputAdornment position="end">
                            <IconButton onClick={() => setShowPassword(!showPassword)}>
                                {showPassword ? <VisibilityRounded fontSize="small"/> : <VisibilityOffRounded fontSize="small"/>}
                            </IconButton>
                        </InputAdornment>
                    }}/>
            </Box>
        </Stack>
    )
}