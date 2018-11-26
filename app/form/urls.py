from django.urls import path

from . import views

urlpatterns = [
    path('', views.simple_upload),
    path('<str:file_path>', views.get_file),
]
