from django.urls import path
from app.controllers.auth_controller import AuthController
from app.controllers.dashboard_controller import DashboardController
from app.controllers.product_controller import ProductController
from app.controllers.category_controller import CategoryController
from app.controllers.sale_controller import SaleController
from app.controllers.report_controller import ReportController
from app.controllers.config_controller import ConfigController

urlpatterns = [
    path('', DashboardController.index, name='dashboard'),
    path('login/', AuthController.login, name='login'),
    path('register/', AuthController.register, name='register'),
    path('logout/', AuthController.logout, name='logout'),
    path('productos/', ProductController.index, name='products'),
    path('productos/crear/', ProductController.create, name='products_create'),
    path('productos/<int:product_id>/editar/', ProductController.edit, name='products_edit'),
    path('productos/<int:product_id>/eliminar/', ProductController.delete, name='products_delete'),
    path('categorias/', CategoryController.index, name='categories'),
    path('ventas/', SaleController.index, name='sales'),
    path('reportes/', ReportController.index, name='reports'),
    path('configuracion/', ConfigController.index, name='config'),
]
