import { Restaurant } from "../types/restaurant";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "../components/ui/card";
import { Star, StarHalf, MapPin, Clock, Phone, Wifi, Car, Truck } from "lucide-react";
import { getPriceRangeString, getStarRating } from "../utils/ratingUtils";
import { Link } from "react-router-dom";
import { Carousel, CarouselContent, CarouselItem } from "../components/ui/carousel";

interface RestaurantCardProps {
  restaurant: Restaurant;
}

const RestaurantCard = ({ restaurant }: RestaurantCardProps) => {
  const {
    id = "unknown",
    name = "Unknown Restaurant",
    cuisine = "Unknown Cuisine",
    address1 = "",
    address2 = "",
    image = "default-image-url.jpg", // 🔧 Анхдагч зураг
    rating = 5,
    priceRange = 1,
    description = "No description available.",
  } = restaurant;

  const stars = getStarRating(rating);
  const ratingValue = rating ? rating.toFixed(1) : "N/A";
  const priceRangeString = getPriceRangeString(priceRange) || "Unknown";

  return (
    <Link to={`/restaurant/${id}`}>
      <Card className="overflow-hidden h-full hover:shadow-lg transition-shadow duration-300">
        {/* Image Gallery */}
        <div className="aspect-video w-full overflow-hidden relative">
          {restaurant.additional_images && restaurant.additional_images.length > 0 ? (
            <Carousel className="w-full h-full">
              <CarouselContent>
                <CarouselItem>
                  <img 
                    src={image} 
                    alt={`${name} main image`}
                    className="w-full h-full object-cover"
                    loading="lazy"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = "default-image-url.jpg";
                    }}
                  />
                </CarouselItem>
                {restaurant.additional_images.map((img, index) => (
                  <CarouselItem key={index}>
                    <img 
                      src={img.image} 
                      alt={`${name} image ${index + 1}`}
                      className="w-full h-full object-cover"
                      loading="lazy"
                    />
                  </CarouselItem>
                ))}
              </CarouselContent>
            </Carousel>
          ) : (
            <img 
              src={image} 
              alt={`${name} main image`}
              className="w-full h-full object-cover"
              loading="lazy"
              onError={(e) => {
                (e.target as HTMLImageElement).src = "default-image-url.jpg";
              }}
            />
          )}
        </div>

        {/* Рестораны үндсэн мэдээлэл */}
        <CardHeader className="p-4 pb-2">
          <div className="flex justify-between items-start">
            <CardTitle className="text-xl font-bold">{name}</CardTitle>
            <span className="text-sm font-medium text-muted-foreground">
              {priceRangeString}
            </span>
          </div>
          <CardDescription className="flex items-center gap-1 text-sm">
            <div className="relative flex items-center gap-1 group">
              <div className="flex">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star
                    key={star}
                    className={`h-5 w-5 ${
                      rating >= star
                        ? 'fill-amber-500 text-amber-500'
                        : rating >= star - 0.5
                        ? 'fill-amber-500/50 text-amber-500/50'
                        : 'text-gray-300'
                    }`}
                  />
                ))}
              </div>
              <span className="ml-1 text-amber-600 font-medium text-sm bg-amber-50 px-2 py-0.5 rounded-full">
                {ratingValue}
                <span className="text-xs text-amber-500">/5</span>
              </span>
              <div className="absolute -bottom-8 left-0 bg-gray-800 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                {ratingValue} үнэлгээ
              </div>
            </div>
          </CardDescription>
        </CardHeader>

        {/* Рестораны нэмэлт мэдээлэл */}
        <CardContent className="p-4 pt-0 pb-2 space-y-2">
          <p className="text-sm font-medium">{cuisine}</p>
          
          {(address1 || address2) && (
            <div className="text-sm text-muted-foreground">
              <div className="flex items-center">
                <MapPin className="h-4 w-4 mr-1 text-muted-foreground" /> 
                <span>{address1}</span>
              </div>
              {address2 && (
                <div className="flex items-center ml-5">
                  <span>{address2}</span>
                </div>
              )}
            </div>
          )}

          <div className="space-y-1">
            {restaurant.opening_hours && (
              <p className="text-sm text-muted-foreground flex items-center gap-1">
                <Clock className="h-4 w-4" />
                {restaurant.opening_hours}
              </p>
            )}

            {restaurant.phone && (
              <p className="text-sm text-muted-foreground flex items-center gap-1">
                <Phone className="h-4 w-4" />
                {restaurant.phone}
              </p>
            )}

            <div className="flex gap-2 flex-wrap pt-1">
              {restaurant.has_delivery && (
                <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded-full flex items-center gap-1">
                  <Truck className="h-3 w-3" />
                  Хүргэлт
                </span>
              )}
              {restaurant.has_parking && (
                <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full flex items-center gap-1">
                  <Car className="h-3 w-3" />
                  Зогсоол
                </span>
              )}
              {restaurant.has_wifi && (
                <span className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded-full flex items-center gap-1">
                  <Wifi className="h-3 w-3" />
                  WiFi
                </span>
              )}
            </div>
          </div>
        </CardContent>

        {/* Рестораны тайлбар */}
        <CardFooter className="p-4 pt-2">
          <p className="text-sm text-muted-foreground truncate">{description}</p>
        </CardFooter>
      </Card>
    </Link>
  );
};

export default RestaurantCard;