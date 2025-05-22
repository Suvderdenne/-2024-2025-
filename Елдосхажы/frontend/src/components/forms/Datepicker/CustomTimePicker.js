import {LocalizationProvider, TimePicker} from "@mui/x-date-pickers";
import {AdapterDayjs} from "@mui/x-date-pickers/AdapterDayjs";
import {FormLabel, Stack} from "@mui/material";
import React from "react";

const CustomTimePicker = (props) => {
    const { label, ...rest } = props;

    return (
        <LocalizationProvider dateAdapter={AdapterDayjs}>
            <Stack sx={{ width: '100%' }}>
                {label && (
                    <FormLabel>{label}</FormLabel>
                )}
                <TimePicker
                    clearable
                    ampm={false}
                    {...rest}/>
            </Stack>
        </LocalizationProvider>
    )
};

export default CustomTimePicker;
