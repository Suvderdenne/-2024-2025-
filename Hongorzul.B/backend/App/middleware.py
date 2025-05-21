from django.utils.deprecation import MiddlewareMixin
from django.http import JsonResponse
from .models import Customer

class TokenAuthenticationMiddleware(MiddlewareMixin):
    def process_request(self, request):
        token = request.headers.get("Authorization")
        if token:
            try:
                customer = Customer.objects.get(token=token)
                request.user = customer
            except Customer.DoesNotExist:
                return JsonResponse({"error": "Invalid Token"}, status=401)
