import os
from django.conf import settings
from django.http import HttpResponse
from django.urls import path

# Configuración mínima de Django
if not settings.configured:
    settings.configure(
        DEBUG=True,
        SECRET_KEY='dev',
        ALLOWED_HOSTS=['*'],
        ROOT_URLCONF=__name__,
        MIDDLEWARE=['django.middleware.common.CommonMiddleware'],
    )

# Vista simple
def home(request):
    return HttpResponse('Hola Mundo ee')

# URLs
urlpatterns = [
    path('', home),
]

# Iniciar servidor
if __name__ == '__main__':
    import django
    django.setup()
    from django.core.management import execute_from_command_line
    execute_from_command_line(['', 'runserver', '0.0.0.0:8081'])