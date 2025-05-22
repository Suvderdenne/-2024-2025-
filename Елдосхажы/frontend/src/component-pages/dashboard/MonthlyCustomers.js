import {Box, Stack, Typography, useTheme} from "@mui/material";
import {Grid3x3} from "@mui/icons-material";
import DashboardCard from "components/cards/DashboardCard";
import Chart from 'react-apexcharts'
import moment from "moment/moment";
import useSWR from "swr";
import {GetProjectsByQuery} from "../../service/project";
import {DefaultSwrOptions} from "../../constants/constants";

const DashboardMonthlyCustomers = ({ data }) => {
    const theme = useTheme();
    const primary = theme.palette.primary.main;
    
    const optionsColumnChart = {
        chart: {
            type: 'bar',
            fontFamily: "'Poppins', sans-serif;",
            foreColor: '#adb0bb',
            toolbar: {
                show: false,
            },
            height: 280,
        },
        colors: Array(12).fill(primary),
        plotOptions: {
            bar: {
                borderRadius: 4,
                columnWidth: '45%',
                distributed: true,
                endingShape: 'rounded',
            },
        },
        dataLabels: {
            enabled: false,
        },
        legend: {
            show: false,
        },
        grid: {
            yaxis: {
                lines: {
                    show: false,
                },
            },
        },
        xaxis: {
            categories: Array(12).fill(0).map((e, i) => moment().month(i).format('MMM')),
            axisBorder: {
                show: false,
            },
        },
        yaxis: {
            labels: {
                show: false,
            },
        },
        tooltip: {
            theme: theme.palette.mode === 'dark' ? 'dark' : 'light',
        },
    };
    const seriesColumnChart = [
        {
            name: '',
            data: [20, 15, 30, 25, 10, 15],
        },
    ];

    // return (
    //     <DashboardCard
    //         title="Үйлчлүүлэгчид"
    //         subtitle="Сар бүрийн үйлчлүүлэгчид">
    //         <Chart
    //             options={optionsColumnChart}
    //             series={[
    //                 {
    //                     name: '',
    //                     data: data,
    //                 },
    //             ]}
    //             type="bar"
    //             height={280}
    //             width={"100%"} />
    //         <Stack direction="row" spacing={2} alignItems="center" sx={{ marginTop: 2 }}>
    //             <Box
    //                 width={38}
    //                 height={38}
    //                 bgcolor="primary.light"
    //                 display="flex"
    //                 alignItems="center"
    //                 justifyContent="center"
    //             >
    //                 <Typography
    //                     color="primary.main"
    //                     display="flex"
    //                     alignItems="center"
    //                     justifyContent="center"
    //                 >
    //                     <Grid3x3 width={22} />
    //                 </Typography>
    //             </Box>
    //             <Box>
    //                 <Typography variant="subtitle2" color="textSecondary">
    //                     Нийт зардал
    //                 </Typography>
    //                 <Typography variant="h6" fontWeight="600">
    //                     {data?.reduce((prev, curr) => prev + curr, 0)}
    //                 </Typography>
    //             </Box>
    //         </Stack>
    //     </DashboardCard>
    // )
};

export default DashboardMonthlyCustomers;