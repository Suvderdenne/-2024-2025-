import PropTypes from 'prop-types';
import {Box, Card, CardContent, styled, Typography, useTheme} from "@mui/material";

const IconBox = styled(Box)(({ theme, color }) => ({
    width: 50,
    height: 50,
    backgroundColor: color,
    borderRadius: 15,
    position: 'absolute',
    right: 10,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
}));

const DashboardWidget = (props) => {
    const { color, content, icon: Component, title } = props;
    const theme = useTheme();

    return (
        <Box sx={{ position: 'relative' }}>
            <IconBox color={theme.palette[color]?.main ?? theme.palette.primary.main}>
                <Component sx={{ width: 30, color: theme.palette[color]?.contrastText ?? theme.palette.primary.contrastText }}/>
            </IconBox>
            <Box sx={{ height: 20 }}/>
            <Card>
                <CardContent>
                    <Box>
                        <Typography sx={{ fontSize: 11, color: theme.palette.text.secondary }}>{title}</Typography>
                    </Box>
                    <Typography variant="h2" sx={{ color: theme.palette.text.primary }}>{content}</Typography>
                </CardContent>
            </Card>
        </Box>
    )
};

DashboardWidget.propTypes = {
    color: PropTypes.string,
    content: PropTypes.string,
    icon: PropTypes.string,
    title: PropTypes.string,
};

export default DashboardWidget;