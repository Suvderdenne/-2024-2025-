import React from "react";
import {Box, Stack, styled, Typography} from "@mui/material";

const FilePickerBox = styled(Box)(({theme, width, height}) => ({
    padding: '10px 30px',
    fontSize: 14,
    fontWeight: 600,
    borderRadius: 10,
    color: theme.palette.grey[300],
    border: `${theme.palette.grey[200]} 2px solid`,
}));

const FilePicker = ({ file, onChange, width, height }) => {
    return (
        <Stack alignItems="start">
            <label>
                <FilePickerBox htmlFor="picker" width={width} height={height}>
                    {file ? (
                        <Typography>{file.name}</Typography>
                    ) : (
                        <Typography>Select File</Typography>
                    )}
                </FilePickerBox>
                <input id="picker" hidden type="file" onChange={onChange}/>
            </label>
        </Stack>
    )
};

export default FilePicker;
