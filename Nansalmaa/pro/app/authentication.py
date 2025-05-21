from rest_framework.authentication import TokenAuthentication
from rest_framework.exceptions import AuthenticationFailed

class BearerTokenAuthentication(TokenAuthentication):
    keyword = 'Bearer'

    def authenticate_credentials(self, key):
        model = self.get_model()
        try:
            token = model.objects.select_related('user').get(key=key)
            if not token.user.is_active:
                raise AuthenticationFailed('User inactive or deleted.')
            return (token.user, token)
        except model.DoesNotExist:
            raise AuthenticationFailed('Invalid token.') 