import {useState} from "react";
import {DefaultSort} from "../../constants/sort";
import useSWR from "swr";
import Breadcrumb from "../../components/Breadcrumb";
import {
    Box, Button, ButtonGroup,
    Card,
    CardContent, Chip,
    CircularProgress, Fab, IconButton, Pagination,
    Stack,
    Table, TableBody, TableCell,
    TableContainer,
    TableHead,
    TableRow, Tooltip
} from "@mui/material";
import EnhancedTableToolbar from "../../components/table/EnhancedTableToolbar";
import CustomCheckbox from "../../components/forms/CustomCheckbox";
import {Link} from "react-router-dom";
import {AddRounded, EditRounded} from "@mui/icons-material";
import DeleteConfirmDialog from "../../components/dialogs/DeleteConfirmDialog";
import {DeleteProject, GetProjectsByQuery} from "../../service/project";

export default function Project() {
    const [filter, setFilter] = useState({sort: DefaultSort.newest.value, limit: 20});
    const [deleteConfirm, setDeleteConfirm] = useState(false);
    const [selectedItems, setSelectedItems] = useState([]);

    const { data: resData, isLoading: loading, mutate } = useSWR(['/api/project', filter],
        () => GetProjectsByQuery(filter), {
            revalidateOnFocus: false,
            revalidateOnReconnect: false,
        });

    const handleSelectItems = (id) => {
        if (selectedItems.includes(id)) {
            setSelectedItems(selectedItems.filter(e => e !== id));
        } else {
            setSelectedItems([...selectedItems, id]);
        }
    };

    const handleSelectStatus = (value) => {
        setFilter({ status: value });
    };

    const handleDelete = () => {
        return DeleteProject(selectedItems.join(',')).then((res) => {
            if (res.status === 200) {
                mutate();
                setDeleteConfirm(false);
                setSelectedItems([]);
            }
        });
    }

    return (
        <>
            <Breadcrumb
                title="Төсөл"
                items={[
                    { to: '/app', title: 'Хяналтын самбар' },
                    { title: 'Төсөл' },
                ]}/>
            <Card>
                <CardContent>
                    <EnhancedTableToolbar
                        filter={filter}
                        numSelected={selectedItems.length}
                        handleChange={(newFilter) => setFilter({...filter, ...newFilter})}
                        sortItems={DefaultSort}
                        onDelete={() => setDeleteConfirm(true)}
                        actions={
                            <ButtonGroup variant="outlined" size="small">
                                <Button
                                    onClick={() => handleSelectStatus(null)}
                                    variant={filter?.status === null ? 'contained' : 'outlined'}>Бүгд</Button>
                                <Button
                                    sx={{ width: 100 }}
                                    onClick={() => handleSelectStatus(true)}
                                    variant={filter?.status ? 'contained' : 'outlined'}>Идэвхтэй</Button>
                                <Button
                                    sx={{ width: 100 }}
                                    onClick={() => handleSelectStatus(false)}
                                    variant={filter?.status === false ? 'contained' : 'outlined'}>Дууссан</Button>
                            </ButtonGroup>
                        }>
                    </EnhancedTableToolbar>
                    {loading || loading === undefined ? (
                        <Stack alignItems="center">
                            <Box height={20}/>
                            <CircularProgress size={32}/>
                        </Stack>
                    ) : (
                        <>
                            <TableContainer>
                                <Table sx={{ whiteSpace: 'nowrap' }}>
                                    <TableHead>
                                        <TableRow>
                                            <TableCell/>
                                            <TableCell>Төслийн нэр</TableCell>
                                            <TableCell>Ахиц дэвшил</TableCell>
                                            <TableCell>Төлөв</TableCell>
                                            <TableCell align="right">Засах</TableCell>
                                        </TableRow>
                                    </TableHead>
                                    <TableBody>
                                        {resData?.data?.data?.length > 0 ? resData?.data?.data?.map((row, i) => (
                                            <TableRow key={i}>
                                                <TableCell padding="checkbox">
                                                    <CustomCheckbox
                                                        color="primary"
                                                        checked={selectedItems.includes(row._id)}
                                                        onChange={() => handleSelectItems(row._id)}/>
                                                </TableCell>
                                                <TableCell>{row?.name}</TableCell>
                                                <TableCell>{row?.progress}%</TableCell>
                                                <TableCell>
                                                    <Chip
                                                        color={row?.status ? 'success' : 'primary'}
                                                        label={row?.status ? 'Идэвхтэй' : 'Дууссан'}
                                                        size="small"/>
                                                </TableCell>
                                                <TableCell align="right">
                                                    <Link to={`/app/project/${row._id}/update`}>
                                                        <Tooltip title="Edit">
                                                            <IconButton>
                                                                <EditRounded fontSize="small" sx={{ color: 'text.secondary'}}/>
                                                            </IconButton>
                                                        </Tooltip>
                                                    </Link>
                                                </TableCell>
                                            </TableRow>
                                        )) : (
                                            <TableRow>
                                                <TableCell colSpan={7} align="center">Өгөгдөл байхгүй</TableCell>
                                            </TableRow>
                                        )}
                                    </TableBody>
                                </Table>
                            </TableContainer>

                            <Stack direction="row" paddingTop={3} justifyContent="end">
                                <Pagination
                                    color="secondary"
                                    count={resData?.data?.pagination?.pages ?? 1}
                                    page={parseInt(resData?.data?.pagination?.page)}
                                    size="small"
                                    onChange={(e, val) => setFilter({...filter, page: val})}/>
                            </Stack>
                        </>
                    )}
                </CardContent>
            </Card>

            <Link to={`/app/project/create`}>
                <Tooltip title="Add Data">
                    <Fab
                        color="primary"
                        aria-label="add"
                        sx={{ position: "fixed", right: "25px", bottom: "15px" }}>
                        <AddRounded />
                    </Fab>
                </Tooltip>
            </Link>

            <DeleteConfirmDialog
                open={deleteConfirm}
                onClose={() => setDeleteConfirm(false)}
                onSubmit={handleDelete}/>
        </>
    )
}