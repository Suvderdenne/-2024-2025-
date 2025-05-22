export const getDatesInMonth = (month, year) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    const dates = [];

    for (let date = startDate; date <= endDate; date.setDate(date.getDate() + 1)) {
        const day = date.getDate();
        dates.push(day);
    }

    return dates;
}

export const getEvenDatesInMonth = (month, year) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);
    const evenDates = [];

    for (let date = startDate; date <= endDate; date.setDate(date.getDate() + 1)) {
        const day = date.getDate();
        if (day % 2 === 0) {
            evenDates.push(day);
        }
    }

    return evenDates;
}

export const getDatesInWeek = (date) => {
    const weekDates = [];
    const startDate = new Date(date);
    startDate.setDate(date.getDate() - date.getDay()); // Get the start date of the week

    for (let i = 0; i < 7; i++) {
        const currentDate = new Date(startDate);
        currentDate.setDate(startDate.getDate() + i);
        weekDates.push(currentDate);
    }

    return weekDates;
}