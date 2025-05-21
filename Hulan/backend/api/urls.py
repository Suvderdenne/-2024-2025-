from django.urls import path
from .views import (
    RegisterView, LoginView, UserProfileView,
    ProductListCreateView, ProductDetailView, ProductSearchView,
    CategoryListView, ProductReviewListView, ReviewCreateView, ReviewCreateOrUpdateView,
    CartView, AddToCartView, UpdateCartItemQuantityView, CartItemDeleteView,
    OrderCreateView
)

urlpatterns = [
    # 👤 User Authentication & Profile
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/', UserProfileView.as_view(), name='user-profile'),

    # 🛍️ Product
    path('products/', ProductListCreateView.as_view(), name='product-list'),
    path('products/<int:product_id>/', ProductDetailView.as_view(), name='product-detail'),
    path('products/search/', ProductSearchView.as_view(), name='product-search'),

    # 📂 Category
    path('categories/', CategoryListView.as_view(), name='category-list'),

    # 🛒 Cart
    path('cart/', CartView.as_view(), name='cart'),
    path('cart/add/', AddToCartView.as_view(), name='add-to-cart'),
    path('cart/items/<int:pk>/update/', UpdateCartItemQuantityView.as_view(), name='update-cart-item'),
    path('cart/items/<int:cart_item_id>/delete/', CartItemDeleteView.as_view(), name='delete-cart-item'),

    # 📦 Orders
    path('orders/', OrderCreateView.as_view(), name='create-order'),

    # 🌟 Reviews
    path('products/<int:product_id>/reviews/', ProductReviewListView.as_view(), name='product-reviews'),
    path('products/<int:product_id>/reviews/add/', ReviewCreateView.as_view(), name='review-create'),
    path('products/<int:product_id>/rate/', ReviewCreateOrUpdateView.as_view(), name='product-rate'),
]
