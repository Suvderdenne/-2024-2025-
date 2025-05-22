export const BasicSort = {
    newest: { name: 'Newest', value: 'createdAt,asc' },
    oldest: { name: 'Oldest', value: 'createdAt,desc' },
};

export const DefaultSort = {
    name: { name: 'Name', value: 'name,asc' },
    ...BasicSort
};