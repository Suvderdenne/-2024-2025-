export interface User {
  id: string;
  name: string;
}

export interface Review {
  id: string;
  user?: {
    id: string;
    name: string;
    username?: string;
  };
  user_name?: string;
  rating: number;
  text: string;
  created_at: string;
  updated_at?: string;
  address?: string;
}

export interface RestaurantImage {
  id: string;
  image: string;
  caption?: string;
}

export interface Restaurant {
  id: string;
  name: string;
  image: string;
  description: string;
  address1: string;
  address2?: string;
  rating?: number;
  priceRange?: number;
  cuisine?: string;
  opening_hours?: string;
  phone?: string;
  website?: string;
  has_delivery?: boolean;
  has_parking?: boolean;
  has_wifi?: boolean;
  popular_dishes?: string;
  additional_images?: RestaurantImage[];
  menu?: {
    id: string;
    name: string;
    description?: string;
    price: number;
    category?: string;
    image?: string; // base64 encoded
    is_available?: boolean;
  }[];
}
