
export const getPriceRangeString = (priceRange: number): string => {
  return '100000₮'.repeat(priceRange);
};

export const getStarRating = (rating: number): { full: number; half: boolean; empty: number } => {
  const fullStars = Math.floor(rating);
  const hasHalfStar = rating % 1 >= 0.5;
  const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
  
  return {
    full: fullStars,
    half: hasHalfStar,
    empty: emptyStars
  };
};
