export const StorageKey = {
    TOKEN: 'token',
    USER: 'user'
};

export const DefaultSwrOptions = {
    revalidateOnFocus: false,
    revalidateOnReconnect: false,
}
export const Role = {
    admin: { name: 'Менежер/Админ', value: 'admin' },
    employee: { name: 'Ажилтан', value: 'employee' }
}

export const LeaveStatus = {
    pending: { name: 'Хүлээгдэж буй', value: 'pending' },
    approved: { name: 'Зөвшөөрөгдсөн', value: 'approved' },
}

export const ExpenseStatus = {
    pending: { name: 'Хүлээгдэж буй', value: 'pending' },
    completed: { name: 'Зөвшөөрөгдсөн', value: 'completed' },
}