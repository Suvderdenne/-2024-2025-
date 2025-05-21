from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from .models import User
import logging

logger = logging.getLogger(__name__)

class UUIDTokenAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return None

        if not auth_header.startswith("Token "):
            raise AuthenticationFailed('Authorization header must start with "Token "')

        token = auth_header.split(" ")[1]
        logger.debug(f"Token received: {token}")

        try:
            user = User.nodes.get(token=token)
            return (user, None)
        except User.DoesNotExist:
            raise AuthenticationFailed('Invalid or expired token')

    def authenticate_header(self, request):
        return 'Token'
