import React from 'react';
import { Button, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions } from '@mui/material';
import PropTypes from "prop-types";

const DeleteConfirmDialog = ({ open, onClose, onSubmit }) => {
    return (
        <Dialog
            open={open ?? false}
            onClose={onClose}
            aria-labelledby="alert-dialog-title"
            aria-describedby="alert-dialog-description">
            <DialogTitle id="alert-dialog-title">
                Delete Confirmation
            </DialogTitle>
            <DialogContent>
                <DialogContentText id="alert-dialog-description">
                Та энэ өгөгдлийг устгахдаа итгэлтэй байна уу?
                </DialogContentText>
            </DialogContent>
            <DialogActions>
                <Button onClick={onClose} sx={{ color: 'grey'}}>Cancel</Button>
                <Button color="error" onClick={onSubmit} autoFocus>
                    Устгах
                </Button>
            </DialogActions>
        </Dialog>
    );
}

DeleteConfirmDialog.propTypes = {
    open: PropTypes.bool,
    onClose: PropTypes.func,
    onSubmit: PropTypes.func
};

export default DeleteConfirmDialog;
