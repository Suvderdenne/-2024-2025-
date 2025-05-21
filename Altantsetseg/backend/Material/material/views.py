from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth import get_user_model
from .models import Material, Order
from .serializers import MaterialSerializer, OrderSerializer, UserSerializer

User = get_user_model()

# ✅ Хэрэглэгч бүртгэх API
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()  # serializer дотор set_password() аль хэдийн байгаа
            return Response({"message": "Хэрэглэгч амжилттай бүртгэгдлээ"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ✅ Материал жагсаалт
@api_view(['GET'])
def get_materials(request):
    materials = Material.objects.all()
    serializer = MaterialSerializer(materials, many=True, context={'request': request})
    return Response(serializer.data)

# ✅ Материал нэмэх
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_material(request):
    serializer = MaterialSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ✅ Захиалга илгээх
class OrderCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = {
            'name': request.data.get('customer_name'),
            'phone': request.data.get('phone_number'),
            'address': request.data.get('delivery_address'),
            'total_price': request.data.get('total_amount'),
            'items': request.data.get('items')
        }

        serializer = OrderSerializer(data=data)
        if serializer.is_valid():
            order = serializer.save()
            return Response({
                "order_id": f"ORD{order.id:06d}",
                "order_date": order.created_at.strftime("%Y-%m-%d"),
                "total": order.total_price,
                "message": "Захиалга амжилттай бүртгэгдлээ"
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        # Захиалгыг хадгалах
        serializer = OrderSerializer(data=request.data)
        if serializer.is_valid():
            order = serializer.save(user=request.user)
            return Response({
                "order_id": f"ORD{order.id:06d}",
                "order_date": order.created_at.strftime("%Y-%m-%d"),
                "total": order.total_price,
                "message": "Захиалга амжилттай бүртгэгдлээ"
            }, status=status.HTTP_201_CREATED)
        
        # Серийн алдаа байгаа бол
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class MockQPayPaymentView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        amount = request.data.get('amount')
        if not amount:
            return Response({'detail': 'Дүн заавал хэрэгтэй'}, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'invoice_id': 'MOCK123456',
            'qr_code': 'https://api.qrserver.com/v1/create-qr-code/?data=MOCK123456&size=200x200',
            'status': 'waiting_payment',
            'amount': amount,
        }, status=status.HTTP_200_OK)


   