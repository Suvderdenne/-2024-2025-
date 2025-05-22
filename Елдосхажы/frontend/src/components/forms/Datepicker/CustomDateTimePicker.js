import {Stack} from "@mui/material";
import {AdapterDayjs} from "@mui/x-date-pickers/AdapterDayjs";
import {DatePicker} from "@mui/x-date-pickers/DatePicker";
import {DateTimePicker, LocalizationProvider} from "@mui/x-date-pickers";
import React from "react";
import dayjs from "dayjs";

const CustomDateTimePicker = (props) => {
    const { label, required, minDate, value, ...rest } = props;

    return (
        <LocalizationProvider dateAdapter={AdapterDayjs}>
            <Stack sx={{ width: '100%' }}>
                <DateTimePicker
                    minDate={minDate ? dayjs(minDate) : null}
                    value={value ? dayjs(value) : null}
                    onError={(e, v) => console.log(e, v)}
                    {...rest} />
            </Stack>
        </LocalizationProvider>
    )
};

export default CustomDateTimePicker;
