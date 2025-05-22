
import { useState } from "react";
import { Star } from "lucide-react";

interface StarRatingProps {
  initialRating?: number;
  onChange?: (rating: number) => void;
  readOnly?: boolean;
  size?: "sm" | "md" | "lg";
}

const StarRating = ({ 
  initialRating = 0, 
  onChange, 
  readOnly = false,
  size = "md" 
}: StarRatingProps) => {
  const [rating, setRating] = useState(initialRating);
  const [hoverRating, setHoverRating] = useState(0);
  
  const handleRatingChange = (newRating: number) => {
    if (readOnly) return;
    
    setRating(newRating);
    onChange?.(newRating);
  };
  
  const sizeClass = {
    sm: "h-4 w-4",
    md: "h-5 w-5",
    lg: "h-6 w-6"
  }[size];
  
  return (
    <div className="flex items-center">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={`${sizeClass} ${
            readOnly ? "" : "cursor-pointer"
          } ${
            star <= (hoverRating || rating)
              ? "text-amber-500 fill-current"
              : "text-gray-300"
          }`}
          onMouseEnter={() => !readOnly && setHoverRating(star)}
          onMouseLeave={() => !readOnly && setHoverRating(0)}
          onClick={() => handleRatingChange(star)}
        />
      ))}
    </div>
  );
};

export default StarRating;
