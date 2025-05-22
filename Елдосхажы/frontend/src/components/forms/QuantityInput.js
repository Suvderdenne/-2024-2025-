import {Box, Stack, styled} from "@mui/material";
import {AddRounded, RemoveRounded} from "@mui/icons-material";

const ActionButton = styled(Box)(({ theme }) => ({
    width: 30,
    height: 30,
    borderRadius: 10,
    border: `1px solid`,
    borderColor: theme.palette.grey['200'],
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
}));

const Input = styled("input")(({ theme }) => ({
    width: 40,
    height: 30,
    border: 'none',
    background: 'transparent',
    textAlign: 'center',
    color: theme.palette.text.primary,

    ':focus': {
        border: 'none',
        outline: 'none'
    }
}));

const QuantityInput = (props) => {
    const { onChange, value } = props;

    return (
        <Stack direction="row" alignItems="center">
            <ActionButton onClick={() => onChange(value - 1)}>
                <RemoveRounded sx={{ fontSize: 14, color: 'text' }}/>
            </ActionButton>
            <Input value={value}/>
            <ActionButton onClick={() => onChange(value + 1)}>
                <AddRounded sx={{ fontSize: 14, color: 'text' }}/>
            </ActionButton>
        </Stack>
    )
};

export default QuantityInput;