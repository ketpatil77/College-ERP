import json
from pathlib import Path

from django.conf import settings


LOCAL_CREDENTIALS_PATH = Path(settings.BASE_DIR) / "local_credentials.json"


def get_local_credential(email, password):
    if not email or not password or not LOCAL_CREDENTIALS_PATH.exists():
        return None

    with LOCAL_CREDENTIALS_PATH.open(encoding="utf-8") as credentials_file:
        payload = json.load(credentials_file)

    for user in payload.get("users", []):
        if user.get("email", "").lower() == email.lower() and user.get("password") == password:
            return user
    return None


def apply_local_credential(user, credential):
    changed_fields = []
    field_defaults = {
        "email": credential["email"],
        "user_type": str(credential.get("user_type", "1")),
        "first_name": credential.get("first_name", ""),
        "last_name": credential.get("last_name", ""),
        "is_staff": bool(credential.get("is_staff", False)),
        "is_superuser": bool(credential.get("is_superuser", False)),
        "is_active": bool(credential.get("is_active", True)),
    }

    for field, value in field_defaults.items():
        if getattr(user, field) != value:
            setattr(user, field, value)
            changed_fields.append(field)

    if not user.check_password(credential["password"]):
        user.set_password(credential["password"])
        changed_fields.append("password")

    if changed_fields:
        user.save(update_fields=changed_fields)

    return user
