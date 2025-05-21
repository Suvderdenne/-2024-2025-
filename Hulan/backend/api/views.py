from decimal import Decimal
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model, authenticate
from django.contrib.auth.hashers import make_password
from rest_framework.response import Response
from rest_framework import status, viewsets
from rest_framework.views import APIView
from rest_framework.generics import ListAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from .models import Order, OrderItem, Product, Cart, CartItem, Review, Category
from .serializers import ProductSerializer, CartSerializer, ReviewSerializer, CartItemSerializer, OrderSerializer
from .product_service import ProductService
from rest_framework import permissions
from .serializers import OrderSerializer
User = get_user_model()

class ProductListCreateView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        category_name = request.query_params.get("category")
        if category_name:
            products = Product.objects.filter(category__name__iexact=category_name)
        else:
            products = Product.objects.all()
        serializer = ProductSerializer(products, many=True, context={"request": request})
        return Response(serializer.data)

    def post(self, request):
        try:
            name = request.data.get('name')
            description = request.data.get('description')
            price = request.data.get('price')
            stock_quantity = request.data.get('stock_quantity')
            image_url = request.data.get('image_url')
            category_id = request.data.get('category')

            product = Product.objects.create(
                name=name,
                description=description,
                price=price,
                stock_quantity=stock_quantity,
                image_url=image_url,
                category_id=category_id
            )
            serializer = ProductSerializer(product, context={"request": request})
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST) 

class ProductDetailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, product_id):
        product = get_object_or_404(Product, id=product_id)
        serializer = ProductSerializer(product, context={"request": request})
        return Response(serializer.data)

    def put(self, request, product_id):
        product = ProductService.update_product(product_id, **request.data)
        serializer = ProductSerializer(product)
        return Response(serializer.data)

    def delete(self, request, product_id):
        ProductService.delete_product(product_id)
        return Response(status=status.HTTP_204_NO_CONTENT)

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')

        if not username or not email or not password:
            return Response({"error": "Бүх талбарыг бөглөнө үү"}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return Response({"error": "Username already exists"}, status=status.HTTP_400_BAD_REQUEST)
        if User.objects.filter(email=email).exists():
            return Response({"error": "Email already registered"}, status=status.HTTP_400_BAD_REQUEST)

        User.objects.create(username=username, email=email, password=make_password(password))
        return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")

        user = authenticate(username=username, password=password)
        if user:
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'username': user.username,
                'is_admin': user.is_staff
            })
        return Response({"error": "Нэвтрэх нэр эсвэл нууц үг буруу байна."}, status=status.HTTP_401_UNAUTHORIZED)

class CartView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cart, _ = Cart.objects.get_or_create(user=request.user)
        serializer = CartSerializer(cart)
        return Response(serializer.data)

    def post(self, request):
        if Cart.objects.filter(user=request.user).exists():
            return Response({"message": "Cart already exists for this user"}, status=status.HTTP_400_BAD_REQUEST)
        cart = Cart.objects.create(user=request.user)
        serializer = CartSerializer(cart)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def delete(self, request):
        cart = get_object_or_404(Cart, user=request.user)
        cart.delete()
        return Response({"message": "Cart deleted"}, status=status.HTTP_204_NO_CONTENT)

class UpdateCartItemQuantityView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        cart_item = get_object_or_404(CartItem, pk=pk, cart__user=request.user)
        quantity = request.data.get("quantity")

        if not quantity:
            return Response({"error": "Тоо дутуу байна"}, status=400)

        quantity = int(quantity)
        if quantity < 1:
            return Response({"error": "Тоо 1-ээс их байх ёстой"}, status=400)

        cart_item.quantity = quantity
        cart_item.save()
        return Response({"message": "Тоо шинэчлэгдлээ"}, status=200)

class AddToCartView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        product_id = request.data.get('product_id')
        quantity = int(request.data.get('quantity', 1))
        product = get_object_or_404(Product, id=product_id)

        if quantity > product.stock_quantity:
            return Response({"error": "Үлдэгдэл хүрэлцэхгүй байна."}, status=status.HTTP_400_BAD_REQUEST)

        cart, _ = Cart.objects.get_or_create(user=request.user)
        cart_item, created = CartItem.objects.get_or_create(cart=cart, product=product)

        cart_item.quantity = quantity if created else cart_item.quantity + quantity
        cart_item.save()

        return Response({
            "message": "Сагсанд амжилттай нэмэгдлээ",
            "cart_item": CartItemSerializer(cart_item).data
        }, status=status.HTTP_201_CREATED)

class CartItemDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, cart_item_id):
        item = get_object_or_404(CartItem, id=cart_item_id, cart__user=request.user)
        item.delete()
        return Response({"message": "Item deleted"}, status=204)

class OrderCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = OrderSerializer(data=request.data, context={"request": request})
        if serializer.is_valid():
            order = serializer.save()
            return Response({
                "message": "Захиалга амжилттай бүртгэгдлээ!",
                "order_id": order.id,
                "total": order.total_amount
            }, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ProductSearchView(ListAPIView):
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        query = self.request.query_params.get('q', '')
        category_name = self.request.query_params.get('category', '')
        qs = Product.objects.all()
        if query:
            qs = qs.filter(name__icontains=query)
        if category_name:
            qs = qs.filter(category__name__icontains=category_name)
        return qs

class ReviewCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, product_id):
        product = get_object_or_404(Product, id=product_id)
        if Review.objects.filter(product=product, user=request.user).exists():
            return Response({"error": "Та энэ бүтээгдэхүүнд аль хэдийн сэтгэгдэл үлдээсэн байна."}, status=400)
        serializer = ReviewSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user, product=product)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)

class ReviewCreateOrUpdateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, product_id):
        product = get_object_or_404(Product, id=product_id)
        rating = int(request.data.get("rating", 0))
        comment = request.data.get("comment", "")

        if rating not in [1, 2, 3, 4, 5]:
            return Response({"error": "Rating must be between 1 and 5"}, status=400)

        review, created = Review.objects.update_or_create(
            user=request.user,
            product=product,
            defaults={"rating": rating, "comment": comment}
        )

        product.update_average_rating()
        return Response({
            "success": True,
            "created": created,
            "review": ReviewSerializer(review).data,
            "average_rating": product.average_rating
        }, status=201)

class ProductReviewListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, product_id):
        product = get_object_or_404(Product, id=product_id)
        reviews = product.reviews.all()
        serializer = ReviewSerializer(reviews, many=True)
        return Response(serializer.data)

class CategoryListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        categories = Category.objects.all()
        return Response([category.name for category in categories])

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response({"username": user.username, "email": user.email, "is_admin": user.is_staff})
