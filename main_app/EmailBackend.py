from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model

from .local_auth import apply_local_credential, get_local_credential


class EmailBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        UserModel = get_user_model()
        local_credential = get_local_credential(username, password)
        if local_credential:
            user, _ = UserModel.objects.get_or_create(
                email=local_credential["email"],
                defaults={
                    "user_type": str(local_credential.get("user_type", "1")),
                    "first_name": local_credential.get("first_name", ""),
                    "last_name": local_credential.get("last_name", ""),
                    "is_staff": bool(local_credential.get("is_staff", False)),
                    "is_superuser": bool(local_credential.get("is_superuser", False)),
                    "is_active": bool(local_credential.get("is_active", True)),
                },
            )
            user = apply_local_credential(user, local_credential)
            if self.user_can_authenticate(user):
                return user

        try:
            user = UserModel.objects.get(email=username)
        except UserModel.DoesNotExist:
            return None
        else:
            if user.check_password(password) and self.user_can_authenticate(user):
                return user
        return None
