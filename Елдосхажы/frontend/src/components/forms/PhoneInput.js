import React, {useEffect, useState} from "react";
import MuiPhoneNumber from 'mui-phone-number';
import {GetItem} from "utils/storage";

const PhoneInput = ({ onChange, value }) => {
    const [defaultCountry, setDefaultCountry] = useState('us');

    useEffect(() => {
        const country = GetItem('country');
        setDefaultCountry(country);
    }, [])

    const handleChange = (value) => {
        onChange(value);
    };

    return (
        <MuiPhoneNumber
            fullWidth
            defaultCountry={defaultCountry}
            onChange={handleChange}
            value={value}
            variant="outlined"/>
    )
};

export default PhoneInput;
