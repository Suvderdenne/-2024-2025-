'use client'

import {Box, Stack, Typography, useTheme} from "@mui/material";
import DashboardCard from "components/cards/DashboardCard";
import Chart from 'react-apexcharts'

const DashboardMonthlyExpense = () => {
    const theme = useTheme();
    const primary = theme.palette.primary.main;
    const primarylight = theme.palette.primary.light;
    const errorlight = theme.palette.error.light;

    // chart
    const optionscolumnchart = {
        chart: {
            type: 'area',
            fontFamily: "'Plus Jakarta Sans', sans-serif;",
            foreColor: '#adb0bb',
            toolbar: {
                show: false,
            },
            height: 60,
            sparkline: {
                enabled: true,
            },
            group: 'sparklines',
        },
        stroke: {
            curve: 'smooth',
            width: 2,
        },
        fill: {
            colors: [primarylight],
            type: 'solid',
            opacity: 0.05,
        },
        markers: {
            size: 0,
        },
        tooltip: {
            theme: theme.palette.mode === 'dark' ? 'dark' : 'light',
        },
    };
    const seriescolumnchart = [
        {
            name: '',
            color: primary,
            data: [25, 66, 20, 40, 12, 58, 20],
        },
    ];

    return (
        <DashboardCard title="Сарын зарлага">
            <Chart options={optionscolumnchart} series={seriescolumnchart} type="area" height={60} width={"100%"} />
            <Box height={8}/>
            <Typography variant="h3" fontWeight="700">
                61,820,000₮
            </Typography>
            <Stack direction="row" spacing={1} my={1} alignItems="center">
                <Typography variant="subtitle2" fontWeight="600">
                    +9%
                </Typography>
                <Typography variant="subtitle2" color="textSecondary">
                    Өмнөх жил
                </Typography>
            </Stack>
        </DashboardCard>
    )
};

export default DashboardMonthlyExpense;