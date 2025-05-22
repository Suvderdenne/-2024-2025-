import bcrypt from "bcryptjs";
import { NextResponse } from "next/server";
import User from "@/models/user";
import connectToDatabase from "@/lib/mongodb";

export async function POST(request: Request) {
    const { lastname, firstname, phone, email, password, confirmPassword } = await request.json();

    // Email validation regex function
    const isValidEmail = (email: string) => {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    };

    // Check if any field is missing
    if (!lastname || !firstname || !phone || !email || !password || !confirmPassword) {
        return NextResponse.json({ message: "All fields are required" }, { status: 400 });
    }

    // Validate email format
    if (!isValidEmail(email)) {
        return NextResponse.json({ message: "Invalid email format" }, { status: 400 });
    }

    // Check if password and confirm password match
    if (confirmPassword !== password) {
        return NextResponse.json({ message: "Passwords do not match" }, { status: 400 });
    }

    // Ensure the password is at least 6 characters long
    if (password.length < 6) {
        return NextResponse.json({ message: "Password must be at least 6 characters long" }, { status: 400 });
    }

    try {
        // Connect to database
        await connectToDatabase();

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return NextResponse.json({ message: "User already exists" }, { status: 400 });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new user
        const newUser = new User({
            lastname,
            firstname,
            phone,
            email,
            password: hashedPassword,
        });

        // Save the new user to the database
        await newUser.save();

        // Return success response
        return NextResponse.json({ message: "User created" }, { status: 201 });

    } catch (error) {
        // Handle server errors
        return NextResponse.json({ message: "Something went wrong" }, { status: 500 });
    }
}
