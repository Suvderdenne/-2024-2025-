import {Box, Breadcrumbs, Grid, Typography, useTheme} from "@mui/material";
import {CircleRounded, MenuBookRounded} from "@mui/icons-material";
import PropTypes from "prop-types";
import {cardShadow} from "theme/shadows";
import {Link} from "react-router-dom";

const Breadcrumb = (props) => {
    const { children, items, subtitle, title } = props;
    const theme = useTheme();

    return (
        <Grid
            container
            sx={{
                backgroundColor: "primary.contrastText",
                boxShadow: cardShadow,
                borderRadius: (theme) => theme.shape.borderRadius,
                p: "30px 25px 20px",
                marginBottom: "30px",
                position: "relative",
                overflow: "hidden",
            }}
        >
            <Grid item xs={12} sm={6} lg={8} mb={1}>
                <Typography variant="h4" fontWeight={600}>{title}</Typography>
                <Typography
                    color="textSecondary"
                    variant="subtitle2"
                    fontWeight={400}
                    mt={0.8}
                    mb={0}
                >
                    {subtitle}
                </Typography>
                <Breadcrumbs
                    separator={<CircleRounded sx={{ fontSize: 5 }}/>}
                    sx={{ alignItems: "center", mt: items ? "10px" : "" }}
                    aria-label="breadcrumb"
                >
                    {items
                        ? items.map((item) => (
                            <div key={item.title}>
                                {item.to ? (
                                    <Link to={item.to} passHref>
                                        <Typography color="textSecondary">{item.title}</Typography>
                                    </Link>
                                ) : (
                                    <Typography color="textPrimary">{item.title}</Typography>
                                )}
                            </div>
                        ))
                        : ""}
                </Breadcrumbs>
            </Grid>
            <Grid item xs={12} sm={6} lg={4} display="flex" alignItems="flex-end">
                <Box
                    sx={{
                        display: { xs: "none", md: "block", lg: "flex" },
                        alignItems: "center",
                        justifyContent: "flex-end",
                        width: "100%",
                    }}
                >
                    {children ? (
                        <Box sx={{ top: "0px", position: "absolute" }}>{children}</Box>
                    ) : (
                        <MenuBookRounded
                            sx={{
                                position: 'absolute',
                                top: -10,
                                right: 0,
                                fontSize: 180,
                                color: theme.palette.primary.main,
                                opacity: 0.2
                            }}
                        />
                    )}
                </Box>
            </Grid>
        </Grid>
    )
};

Breadcrumb.propTypes = {
    items: PropTypes.array,
    subtitle: PropTypes.string,
    title: PropTypes.string
};

export default Breadcrumb;