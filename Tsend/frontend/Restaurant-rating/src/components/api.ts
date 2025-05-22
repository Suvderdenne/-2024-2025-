import apiClient from "../utils/auth";

// Рестораны дэлгэрэнгүй мэдээлэл авах
export const fetchRestaurantDetail = async (id: string) => {
  try {
    const response = await apiClient.get(`/restaurants/${id}/`); // Загварыг зөв дуудна
    return response.data;
  } catch (error: any) {
    console.error("Рестораны дэлгэрэнгүй мэдээлэл татахад алдаа гарлаа:", error);
    throw new Error(error.response?.data?.message || "Алдаа гарлаа!");
  }
};

// Рестораны жагсаалт авах
export const fetchRestaurants = async (searchTerm?: string) => {
  try {
    console.log("Searching for:", searchTerm);
    const csrfToken = document.cookie.split('; ')
      .find(row => row.startsWith('csrftoken='))?.split('=')[1];
    
    console.log("Using CSRF token:", csrfToken ? "found" : "not found");
    
    try {
      // Ensure search term is properly encoded
      const params = new URLSearchParams();
      if (searchTerm) {
        params.append('search', searchTerm);
      }

      console.log("Making API request to /restaurants/ with params:", params.toString());
      const response = await apiClient.get("/restaurants/", {
        params: params,
        headers: {
          'X-CSRFToken': csrfToken || '',
          'Content-Type': 'application/json'
        }
      });
      
      // Handle both array and paginated response formats
      const responseData = response.data;
      console.log("Search response:", responseData);
      
      if (Array.isArray(responseData)) {
        return responseData; // Direct array response
      } else if (responseData.results) {
        return responseData.results; // Paginated response
      }
      return []; // Fallback for unexpected formats
    } catch (error: any) {
      console.error("Search API error details:", {
        config: error.config,
        response: error.response?.data,
        status: error.response?.status
      });
      throw error;
    }
  } catch (error: any) {
    console.error("Рестораны жагсаалт татахад алдаа гарлаа:", error);
    if (error.response) {
      console.error("Backend error response:", {
        status: error.response.status,
        data: error.response.data,
        headers: error.response.headers
      });
    }
    throw new Error(error.response?.data?.message || "Сервертэй холбогдоход алдаа гарлаа");
  }
};

// Шинэ ресторан нэмэх
export const addRestaurant = async (restaurant: {
  name: string;
  description: string;
  location: string;
  cuisine: string;
  priceRange: number;
  image: string;
}) => {
  try {
    const response = await apiClient.post("/restaurants", restaurant);
    return response.data;
  } catch (error: any) {
    console.error("Шинэ ресторан нэмэхэд алдаа гарлаа:", error);
    throw new Error(error.response?.data?.message || "Алдаа гарлаа!");
  }
};

// Комментын жагсаалт авах
export const fetchComments = async (restaurantId: string) => {
  try {
    const response = await apiClient.get(`/restaurants/${restaurantId}/comments/`); // Замыг зөв дуудна
    return response.data;
  } catch (error: any) {
    console.error("Комментын жагсаалт татахад алдаа гарлаа:", error);
    throw new Error(error.response?.data?.message || "Алдаа гарлаа!");
  }
};

// Шинэ коммент нэмэх
export const addComment = async (restaurantId: string, comment: { 
  rating: number; 
  text: string 
}) => {
  try {
    const token = localStorage.getItem('authToken');
    console.log("Sending token:", token);  // Log the token for debugging
    
    // Ensure token exists before making the request
    if (!token) {
      throw new Error("Token not found! Please log in.");
    }

    const response = await apiClient.post(`/restaurants/${restaurantId}/comments/`, comment, {
      headers: {
        'Authorization': ` ${token}`,  // Make sure it's "Token" and not "Bearer"
        'Content-Type': 'application/json'
      }
    });
    return response.data;
  } catch (error: any) {
    console.error("Error adding new comment:", error);

    // Handle specific error codes
    if (error.response?.status === 401) {
      throw new Error("Unauthorized! Please log in.");
    }

    // General error handling
    const errorMessage = error.response?.data?.message || error.response?.data?.error || "An error occurred!";
    throw new Error(errorMessage);
  }
};


// Хэрэглэгч бүртгэх
export const registerUser = async (user: { 
  username: string; 
  email: string; 
  password: string 
}) => {
  try {
    const response = await apiClient.post("/register/", user, {
      headers: {
        "Content-Type": "application/json"
      }
    });
    return response.data;
  } catch (error: any) {
    console.error("Хэрэглэгч бүртгэхэд алдаа гарлаа:", error);
    if (error.response) {
      console.error("Backend error details:", error.response.data);
    }
    throw new Error(error.response?.data?.error || "Алдаа гарлаа!");
  }
};

// Хэрэглэгч нэвтрэх
export const loginUser = async (data: { 
  email: string; 
  password: string 
}) => {
  try {
    const response = await apiClient.post("/login/", data, {
      headers: {
        "Content-Type": "application/json"
      }
    });
    if (response.data?.token) {
      localStorage.setItem('authToken', response.data.token);
      apiClient.defaults.headers.common['Authorization'] = `Token ${response.data.token}`;
      return {
        ...response.data,
        authenticated: true
      };
    }
    throw new Error("Token not received from server");
  } catch (error: any) {
    console.error("Backend алдаа:", error.response?.data || error.message);
    throw new Error(error.response?.data?.detail || "Нэвтрэхэд алдаа гарлаа");
  }
};
