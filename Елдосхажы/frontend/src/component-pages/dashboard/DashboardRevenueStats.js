'use client'

import {Avatar, Box, Button, Grid, MenuItem, Select, Stack, Typography, useTheme} from "@mui/material";
import {Grid4x4} from "@mui/icons-material";
import {useEffect, useState} from "react";
import DashboardCard from "components/cards/DashboardCard";
import Chart from 'react-apexcharts'
import useSWR from "swr";
import {GetAnnouncementsByQuery} from "../../service/announcement";
import {DefaultSwrOptions} from "../../constants/constants";
import {GetProjectsByQuery} from "../../service/project";
import moment from "moment";

const DashboardRevenueStats = () => {
    const [month, setMonth] = useState('1');
    const [completed, setCompleted] = useState(Array(12).fill(0));
    const [progress, setProgress] = useState(Array(12).fill(0));

    const { data: resProject, isLoading: loading} = useSWR('/api/project/completed',
        () => GetProjectsByQuery({dashboard: true}), DefaultSwrOptions);

    useEffect(() => {
        const data = resProject?.data?.data;
        if (data) {
            setCompleted(Array(12).fill(0).map((e, i) => data?.completed[i]?.count ?? 0));
            setProgress(Array(12).fill(0).map((e, i) => data?.progressing[i]?.count ?? 0));
        }
    }, [resProject?.data?.data]);

    const handleChange = (event) => {
        setMonth(event.target.value);
    };

    // chart color
    const theme = useTheme();
    const primary = theme.palette.primary.main;
    const secondary = theme.palette.secondary.main;

    // chart
    const optionscolumnchart = {
        chart: {
            type: 'bar',
            fontFamily: "'Poppins', sans-serif;",
            foreColor: '#adb0bb',
            toolbar: { show: true },
            height: 360,
        },
        colors: [primary, secondary],
        plotOptions: {
            bar: {
                horizontal: false,
                barHeight: '60%',
                columnWidth: '30%',
                borderRadius: [6, 6],
                borderRadiusApplication: 'end',
                borderRadiusWhenStacked: 'all',
            },
        },
        stroke: {
            show: false,
        },
        dataLabels: {
            enabled: false,
        },
        legend: {
            show: false,
        },
        grid: {
            borderColor: 'rgba(0,0,0,0.1)',
            strokeDashArray: 3,
            xaxis: {
                lines: {
                    show: false,
                },
            },
        },
        yaxis: {
            min: 0,
            max: 5,
            tickAmount: 4,
        },
        xaxis: {
            categories: Array(12).fill(0).map((e, i) => moment().month(i).format('MMM')),
            axisBorder: {
                show: false,
            },
        },
        tooltip: {
            theme: theme.palette.mode === 'dark' ? 'dark' : 'light',
            fillSeriesColor: false,
        },
    };

    return (
        <DashboardCard
            title="Жилийн төсөл"
            subtitle="Төслийн төлөв байдлын тойм"
        >
            <Grid container spacing={3}>
                {/* column */}
                <Grid item xs={12} sm={9}>
                    <Box className="rounded-bars">
                        <Chart
                            options={optionscolumnchart}
                            series={[
                                {
                                    name: 'Төсөл дууссан',
                                    data: completed,
                                },
                                {
                                    name: 'Төсөл үргэлжилж байна',
                                    data: progress,
                                },
                            ]}
                            type="bar"
                            height={360}
                            width={"100%"}
                        />
                    </Box>
                </Grid>
                {/* column */}
                <Grid item xs={12} sm={3}>
                    <Stack spacing={3} mt={3}>
                        <Stack direction="row" spacing={2} alignItems="center">
                            <Box
                                width={40}
                                height={40}
                                bgcolor="primary.light"
                                display="flex"
                                alignItems="center"
                                justifyContent="center"
                            >
                                <Typography color="primary" variant="h6" display="flex">
                                    <Grid4x4 size={24} />
                                </Typography>
                            </Box>
                            <Box>
                                <Typography variant="h3" fontWeight="700">
                                    {completed.reduce((prev, curr) => prev + curr, 0) + progress.reduce((prev, curr) => prev + curr, 0)}
                                </Typography>
                                <Typography variant="subtitle2" color="textSecondary">
                                Энэ жилийн төсөл
                                </Typography>
                            </Box>
                        </Stack>
                    </Stack>
                    <Stack spacing={3} my={5}>
                        <Stack direction="row" spacing={2}>
                            <Avatar
                                sx={{ width: 9, mt: 1, height: 9, bgcolor: primary, svg: { display: 'none' } }}/>
                            <Box>
                                <Typography variant="subtitle1" color="textSecondary">
                                    Төсөл дууссан
                                </Typography>
                                <Typography variant="h5">{completed.reduce((prev, curr) => prev + curr, 0)}</Typography>
                            </Box>
                        </Stack>
                        <Stack direction="row" spacing={2}>
                            <Avatar
                                sx={{ width: 9, mt: 1, height: 9, bgcolor: secondary, svg: { display: 'none' } }}/>
                            <Box>
                                <Typography variant="subtitle1" color="textSecondary">
                                    Төсөл үргэлжилж байна
                                </Typography>
                                <Typography variant="h5">{progress.reduce((prev, curr) => prev + curr, 0)}</Typography>
                            </Box>
                        </Stack>
                    </Stack>
                </Grid>
            </Grid>
        </DashboardCard>
    );
};

export default DashboardRevenueStats;