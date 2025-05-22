import {useSelector} from "store";
import {Box, Card, CardContent, Stack, Typography, useTheme} from "@mui/material";

const DashboardCard = (props) => {
    const {
        title, subtitle, children, action, footer, cardheading,
        headtitle, headsubtitle, middlecontent,
    } = props;

    return (
        <Card
            sx={{ padding: 0, border: 'none' }}
            elevation={9}
        >
            {cardheading ? (
                <CardContent>
                    <Typography variant="h5">{headtitle}</Typography>
                    <Typography variant="subtitle2" color="textSecondary">
                        {headsubtitle}
                    </Typography>
                </CardContent>
            ) : (
                <CardContent sx={{p: "30px"}}>
                    {title ? (
                        <Stack
                            direction="row"
                            spacing={2}
                            justifyContent="space-between"
                            alignItems={'center'}
                            mb={3}
                        >
                            <Box>
                                {title ? <Typography variant="h5">{title}</Typography> : ''}

                                {subtitle ? (
                                    <Typography variant="subtitle2" color="textSecondary">
                                        {subtitle}
                                    </Typography>
                                ) : (
                                    ''
                                )}
                            </Box>
                            {action}
                        </Stack>
                    ) : null}

                    {children}
                </CardContent>
            )}

            {middlecontent}
            {footer}
        </Card>
    );
};

export default DashboardCard;