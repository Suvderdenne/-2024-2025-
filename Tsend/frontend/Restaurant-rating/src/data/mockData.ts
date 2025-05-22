
import { Restaurant, Review } from "@/types/restaurant";

export const restaurants: Restaurant[] = [
  {
    id: "1",
    name: "Монгол ресторан",
    cuisine: "Монгол",
    address: "Сүхбаатарын талбай, Улаанбаатар",
    image: "https://images.unsplash.com/photo-1514326640560-7d063ef2aed5?q=80&w=1000",
    rating: 4.5,
    priceRange: 3,
    description: "Уламжлалт монгол хоол, тансаг орчин",
  },
  {
    id: "2",
    name: "Солонгос BBQ",
    cuisine: "Солонгос",
    address: "Хан-Уул дүүрэг, Улаанбаатар",
    image: "https://images.unsplash.com/photo-1498654896293-37aacf113fd9?q=80&w=1000",
    rating: 4.2,
    priceRange: 4,
    description: "Шинэхэн солонгос барбекю, онцгой амт",
  },
  {
    id: "3",
    name: "Пицца Палас",
    cuisine: "Итали",
    address: "Сүхбаатар дүүрэг, Улаанбаатар",
    image: "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=1000",
    rating: 4.0,
    priceRange: 2,
    description: "Итали пицца болон гоймон, гэр бүлд зориулсан",
  },
  {
    id: "4",
    name: "Хятад Хотхон",
    cuisine: "Хятад",
    address: "Баянгол дүүрэг, Улаанбаатар",
    image: "https://images.unsplash.com/photo-1563245372-f21724e3856d?q=80&w=1000",
    rating: 4.3,
    priceRange: 3,
    description: "Уламжлалт хятад хоолнууд, тансаг орчин",
  },
  {
    id: "5",
    name: "Япон Суши",
    cuisine: "Япон",
    address: "Чингэлтэй дүүрэг, Улаанбаатар",
    image: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=1000",
    rating: 4.7,
    priceRange: 4,
    description: "Шинэхэн суши болон сашими, япон уур амьсгал",
  },
  {
    id: "6",
    name: "Вегетариан Таверн",
    cuisine: "Цагаан хоол",
    address: "Хан-Уул дүүрэг, Улаанбаатар",
    image: "https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?q=80&w=1000",
    rating: 4.1,
    priceRange: 2,
    description: "Эрүүл цагаан хоол, органик орц",
  }
];

export const reviews: Review[] = [
  {
    id: "1",
    restaurantId: "1",
    userName: "Болд Б.",
    rating: 5,
    comment: "Маш гайхалтай хоол! Уламжлалт амт нь үнэхээр сайхан байлаа.",
    date: "2023-10-15"
  },
  {
    id: "2",
    restaurantId: "1",
    userName: "Оюун С.",
    rating: 4,
    comment: "Үйлчилгээ сайн, хоол амттай. Тансаг орчин.",
    date: "2023-09-20"
  },
  {
    id: "3",
    restaurantId: "2",
    userName: "Баяр Л.",
    rating: 4,
    comment: "Барбекю нь үнэхээр гайхалтай байсан. Дахин очно!",
    date: "2023-10-10"
  },
  {
    id: "4",
    restaurantId: "3",
    userName: "Сараа Б.",
    rating: 3,
    comment: "Пицца нь дунд зэрэг, гэхдээ үйлчилгээ нь сайн байсан.",
    date: "2023-10-05"
  },
  {
    id: "5",
    restaurantId: "4",
    userName: "Билгүүн Д.",
    rating: 5,
    comment: "Хятад хоол нь үнэхээр амттай, орчин тансаг. Заавал үзэж үнэлээрэй.",
    date: "2023-10-12"
  }
];
