import {Box, styled} from "@mui/material";
import Image from "next/image";
import {AddPhotoAlternateOutlined} from "@mui/icons-material";

const ImagePickerBox = styled(Box)(({theme, width, height}) => ({
    width: width ?? 100,
    height: height ?? 100,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 10,
    border: `${theme.palette.mode === 'light' ?
        theme.palette.grey[300] : theme.palette.text.secondary} 1px solid`,
    borderStyle: 'dashed'
}));

const ImagePicker = ({ preview, onChange, width, height }) => {
    return (
        <label>
            {preview ? (
                <Image
                    src={preview}
                    alt="product"
                    htmlFor="picker"
                    width={width} height={height}
                    style={{ objectFit: 'contain', borderRadius: 10 }}/>
            ) : (
                <ImagePickerBox htmlFor="picker" width={width} height={height}>
                    <AddPhotoAlternateOutlined sx={{ color: 'text.secondary' }}/>
                </ImagePickerBox>
            )}
            <input id="picker" hidden type="file" onChange={onChange}/>
        </label>
    )
};

export default ImagePicker;