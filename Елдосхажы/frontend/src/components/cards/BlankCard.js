'use client'

import {Card, useTheme} from "@mui/material";

const BlankCard = ({ children, className, sx, isCardShadow }) => {
    const theme = useTheme();
    const borderColor = theme.palette.divider;

    return (
        <Card
            sx={{ p: 0, border: !isCardShadow ? `1px solid ${borderColor}` : 'none' , position: 'relative', sx }}
            className={className}
            elevation={isCardShadow ? 9 : 0}
            variant={!isCardShadow ? 'outlined' : undefined}
        >
            {children}
        </Card>
    );
};

export default BlankCard;