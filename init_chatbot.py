#!/usr/bin/env python3
"""
Script de inicialización del Chatbot con IA
Crea la tabla necesaria en la base de datos
"""

from config.database import Database
from app.models.chatbot_message import ChatbotMessage

def init_chatbot():
    """Inicializa las tablas necesarias para el chatbot"""
    print("=" * 60)
    print("INICIALIZANDO CHATBOT CON IA")
    print("=" * 60)
    
    try:
        # Crear tabla de mensajes del chatbot
        print("\n[1/2] Creando tabla chatbot_messages...")
        ChatbotMessage.create_table()
        print("✓ Tabla chatbot_messages creada correctamente")
        
        print("\n[2/2] Verificando dependencias...")
        try:
            import google.generativeai as genai
            print("✓ google-generativeai instalado correctamente")
        except ImportError:
            print("✗ ERROR: google-generativeai no está instalado")
            print("\nPara instalar, ejecuta:")
            print("  pip install google-generativeai")
            return False
        
        print("\n" + "=" * 60)
        print("✓ CHATBOT INICIALIZADO CORRECTAMENTE")
        print("=" * 60)
        print("\n CONFIGURACIÓN NECESARIA:")
        print("\n1. Configura tu API Key de Google Gemini:")
        print("   - Obtén tu key en: https://makersuite.google.com/app/apikey")
        print("   - Establece la variable de entorno:")
        print("     export GEMINI_API_KEY='tu-api-key-aqui'")
        print("\n2. Accede al chatbot en: http://localhost:8000/chatbot/")
        print("\n3. El chatbot puede ayudarte con:")
        print("   - Consultas sobre productos e inventario")
        print("   - Resúmenes de ventas y compras")
        print("   - Búsqueda de información")
        print("   - Asistencia general del sistema")
        print("\n" + "=" * 60)
        
        return True
        
    except Exception as e:
        print(f"\n✗ ERROR al inicializar el chatbot: {str(e)}")
        return False

if __name__ == "__main__":
    init_chatbot()
