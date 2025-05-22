const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const userRoutes = require('./routes/user'); // Жаңа маршрутты қосу

const app = express();

// CORS және body parsing middleware орнату
app.use(cors());
app.use(bodyParser.json());

// /app/user маршруттарын қосу
app.use('/app/user', userRoutes);

// MongoDB байланысын орнату
mongoose.connect('mongodb://localhost:27017/test', { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.log("MongoDB connection error:", err));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
