import {
    Box, Button,
    FormLabel,
    IconButton,
    InputAdornment,
    Menu, MenuItem, Select, Stack,
    TextField,
    Toolbar,
    Tooltip,
    Typography
} from "@mui/material";
import {DeleteRounded, FilterListRounded, SearchRounded} from "@mui/icons-material";
import {useState} from "react";
import {BasicSort} from "constants/sort";
import PropTypes from "prop-types";

const EnhancedTableToolbar = (props) => {
    const {
        children,
        filter,
        handleChange,
        numSelected,
        onDelete,
        sortItems,
        actions
    } = props;

    const [filterAnchorEl, setFilterAnchorEl] = useState(null);
    const [tempFilter, setTempFilter] = useState(filter);

    const handleSearch = (e) => {
        setTempFilter({ ...filter, keyword: e.target.value});
        handleChange({...filter, keyword: e.target.value});
    };

    return (
        <Toolbar
            sx={{
                pl: { xs: 0 },
                pr: { xs: 0, sm: 1 },
                borderRadius: 2,
                ...(numSelected > 0 && {
                    pl: 2,
                    background: (theme) => theme.palette.primary.light,
                }),
            }}
        >
            {numSelected > 0 ? (
                <Typography sx={{ flex: '1 1 100%' }} color="inherit" variant="subtitle2" component="div">
                    {numSelected} selected
                </Typography>
            ) : (
                <Box sx={{ flex: '1 1 100%' }}>
                    <TextField
                        InputProps={{
                            startAdornment: (
                                <InputAdornment position="start">
                                    <SearchRounded fontSize="small"/>
                                </InputAdornment>
                            ),
                        }}
                        placeholder="Type your keyword ..."
                        size="small"
                        onChange={(e) => handleSearch(e)}
                        value={tempFilter.keyword}
                    />
                </Box>
            )}

            {numSelected > 0 ? (
                <Tooltip title="Delete">
                    <IconButton onClick={onDelete}>
                        <DeleteRounded width="18" />
                    </IconButton>
                </Tooltip>
            ) : (
                <>
                    {actions && (
                        <Stack direction="row" spacing={2}>
                            {actions}
                        </Stack>
                    )}
                    <Tooltip title="Filter" sx={{ marginLeft: 2 }}>
                        <IconButton onClick={(e) => setFilterAnchorEl(e.currentTarget)}>
                            <FilterListRounded size="1.2rem" />
                        </IconButton>
                    </Tooltip>
                </>
            )}
            <Menu
                anchorEl={filterAnchorEl}
                id="account-menu"
                open={Boolean(filterAnchorEl)}
                onClose={() => setFilterAnchorEl(null)}
                PaperProps={{
                    elevation: 0,
                    sx: {
                        minWidth: 250,
                        borderRadius: 3,
                        overflow: 'visible',
                        filter: 'drop-shadow(0px 2px 8px rgba(0,0,0,0.1))',
                        mt: 1.5,
                    },
                }}
                transformOrigin={{ horizontal: 'right', vertical: 'top' }}
                anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
            >
                <Stack spacing={2} padding={2}>
                    <Box>
                        <FormLabel sx={{ fontSize: 12 }}>Sort By</FormLabel>
                        <Select
                            fullWidth
                            size="small"
                            onChange={(e) => setTempFilter({...filter, sort: e.target.value})}
                            value={tempFilter.sort}>
                            {Object.keys(sortItems || BasicSort).map(key => (
                                <MenuItem key={key} value={(sortItems || BasicSort)[key].value}>
                                    {(sortItems || BasicSort)[key].name}
                                </MenuItem>
                            ))}
                        </Select>
                    </Box>

                    {children}

                    <Button
                        fullWidth
                        color="primary"
                        size="small"
                        variant="contained"
                        onClick={() => {
                            handleChange(tempFilter);
                            setFilterAnchorEl(null);
                        }}>
                        Search
                    </Button>
                </Stack>
            </Menu>
        </Toolbar>
    )
};

EnhancedTableToolbar.propTypes = {
    onDelete: PropTypes.func
};

export default EnhancedTableToolbar;