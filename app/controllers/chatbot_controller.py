from django.http import HttpResponse, HttpResponseRedirect, JsonResponse
from app.models.user import User
from app.models.chatbot_message import ChatbotMessage
from app.services.ai_service import AIService
from app.views.chatbot_view import ChatbotView
import json

class ChatbotController:
    """Controlador del Chatbot con IA"""
    
    @staticmethod
    def index(request):
        """Muestra la interfaz del chatbot"""
        # Verificar autenticación
        user_id = request.session.get('user_id')
        
        if not user_id:
            return HttpResponseRedirect('/login/')
        
        # Obtener datos del usuario
        user = User.get_by_id(user_id)
        
        if not user:
            request.session.flush()
            return HttpResponseRedirect('/login/')
        
        # Obtener historial de conversación
        history = ChatbotMessage.get_history(user_id, limit=20)
        
        # Renderizar vista
        return HttpResponse(ChatbotView.render(user, history))
    
    @staticmethod
    def send_message(request):
        """Procesa un mensaje del usuario y retorna la respuesta de la IA"""
        user_id = request.session.get('user_id')
        if not user_id:
            return JsonResponse({'success': False, 'error': 'No autenticado'}, status=401)
        if request.method != 'POST':
            return JsonResponse({'success': False, 'error': 'Método no permitido'}, status=405)
        try:
            body = json.loads(request.body.decode('utf-8'))
            user_message = body.get('message', '').strip()
            if not user_message:
                return JsonResponse({'success': False, 'error': 'Mensaje vacío'}, status=400)
            try:
                ai_service = AIService()
            except Exception as e:
                return JsonResponse({'success': False, 'error': f'Error de configuración de IA: {str(e)}'}, status=500)
            if user_message.lower() in ['ayuda', 'help', 'hola', 'hi', 'hello']:
                response = ai_service.get_help_message()
            else:
                response = ai_service.process_query(user_message, user_id)
            ChatbotMessage.save(user_id, user_message, response)
            return JsonResponse({'success': True, 'message': user_message, 'response': response})
        except json.JSONDecodeError:
            return JsonResponse({'success': False, 'error': 'JSON inválido'}, status=400)
        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)}, status=500)
    
    @staticmethod
    def clear_history(request):
        """Limpia el historial de conversación del usuario"""
        # Verificar autenticación
        user_id = request.session.get('user_id')
        
        if not user_id:
            return JsonResponse({
                'success': False,
                'error': 'No autenticado'
            }, status=401)
        
        if request.method != 'POST':
            return JsonResponse({
                'success': False,
                'error': 'Método no permitido'
            }, status=405)
        
        try:
            # Eliminar historial
            ChatbotMessage.delete_history(user_id)
            
            return JsonResponse({
                'success': True,
                'message': 'Historial eliminado correctamente'
            })
        except Exception as e:
            return JsonResponse({
                'success': False,
                'error': str(e)
            }, status=500)
    
    @staticmethod
    def get_history(request):
        """Obtiene el historial de conversación"""
        # Verificar autenticación
        user_id = request.session.get('user_id')
        
        if not user_id:
            return JsonResponse({
                'success': False,
                'error': 'No autenticado'
            }, status=401)
        
        try:
            # Obtener historial
            history = ChatbotMessage.get_history(user_id, limit=50)
            
            return JsonResponse({
                'success': True,
                'history': history
            })
        except Exception as e:
            return JsonResponse({
                'success': False,
                'error': str(e)
            }, status=500)
