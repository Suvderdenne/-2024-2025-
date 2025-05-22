import mongoose, { Document, Model, Schema } from "mongoose";

interface IUser extends Document{
    lastname: string;
    firstname: string;
    phone: string;
    email: string;
    password?: string;
    id: string;
}

const UserSchema: Schema<IUser> = new mongoose.Schema({
    lastname: {
        type: String,
        required: true,
    },
    firstname: {
        type: String,
        required:true,
    },
    phone: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: false
    }
})

const User: Model<IUser>=mongoose.models.User || mongoose.model<IUser>("User", UserSchema)

export default User;