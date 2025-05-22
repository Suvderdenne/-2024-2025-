import {Box, Card, CardContent, CardHeader, Divider, useTheme} from "@mui/material";

const ParentCard = ({ title, children, footer }) => {
    return (
        <Card>
            <CardHeader title={title} />
            <Divider />
            <CardContent>{children}</CardContent>
            {footer ? (
                <>
                    <Divider />
                    <Box p={3}>{footer}</Box>
                </>
            ) : (
                ''
            )}
        </Card>
    );
};

export default ParentCard;