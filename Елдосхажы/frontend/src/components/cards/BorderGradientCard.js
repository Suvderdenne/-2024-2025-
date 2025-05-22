'use client'

import {Box, Card, Paper, Stack, styled, Typography} from "@mui/material";
import Image from "next/image";
import PropTypes from "prop-types";

const Background = styled(Card)(({ theme }) => ({
    borderRadius: 15,
    padding: 3,
    background: 'linear-gradient(135deg, hsla(233, 100%, 90%, 0.7) 0%, hsla(0, 0%, 89%, 0.4) 100%)'
}));

const ContentCard = styled(Stack)(({ theme }) => ({
    padding: 10,
    borderRadius: 15,
    backgroundColor: 'rgba(255, 255, 255, 0.7)'
}));

const BorderGradientCard = ({ image, title, subtitle, action }) => {
    return (
        <Paper elevation={0} sx={{ borderRadius: 15 }}>
            <Background elevation={0}>
                <ContentCard alignItems="center" spacing={2}>
                    <Box sx={{
                        width: 300,
                        height: 300,
                        position: 'relative'
                    }}>
                        <Image
                            src="https://res.cloudinary.com/da7dpvbsl/image/upload/v1657614111/Product/img_kb4jb1.png"
                            alt="card"
                            fill
                            style={{ borderRadius: 15, objectFit: 'cover' }}/>
                    </Box>
                    <Stack alignItems="center" sx={{ paddingY: 2 }}>
                        <Typography variant="h5" sx={{ fontWeight: 600 }}>Title</Typography>
                        <Typography variant="subtitle2">Subtitle</Typography>
                    </Stack>
                    <Box height={10}/>
                    {action}
                </ContentCard>
            </Background>
        </Paper>
    )
}

BorderGradientCard.propTypes = {
    action: PropTypes.node
}

export default BorderGradientCard;