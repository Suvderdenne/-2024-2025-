export const SetItem = (key, value) => {
    if (typeof window !== 'undefined') {
        if (typeof value === 'object') {
            return localStorage.setItem(key, JSON.stringify(value));
        }

        return   localStorage.setItem(key, value);
    }
};

export const GetItem = (key) => {
    const value = localStorage.getItem(key);

    if (value) {
        try {
            return JSON.parse(value);
        } catch (error) {
            return value;
        }
    }

    return null;
};

export const RemoveItem = (key) => {
    return localStorage.removeItem(key);
};
