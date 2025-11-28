from config.database import Database
from datetime import datetime

class ChatbotMessage:
    """Modelo para mensajes del chatbot"""
    
    @staticmethod
    def create_table():
        """Crea la tabla de mensajes del chatbot"""
        query = """
        CREATE TABLE IF NOT EXISTS chatbot_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            message TEXT NOT NULL,
            response TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        Database.execute_query(query)
    
    @staticmethod
    def save(user_id, message, response):
        """Guarda un mensaje y su respuesta"""
        query = """
        INSERT INTO chatbot_messages (user_id, message, response, created_at)
        VALUES (%s, %s, %s, %s)
        """
        Database.execute_query(query, (user_id, message, response, datetime.now()), fetch=False)
    
    @staticmethod
    def get_history(user_id, limit=10):
        """Obtiene el historial de conversación del usuario"""
        query = """
        SELECT id, user_id, message, response, created_at
        FROM chatbot_messages
        WHERE user_id = %s
        ORDER BY created_at DESC
        LIMIT %s
        """
        results = Database.execute_query(query, (user_id, limit), fetch=True)
        
        if not results:
            return []
        
        messages = []
        for row in results:
            messages.append({
                'id': row['id'],
                'user_id': row['user_id'],
                'message': row['message'],
                'response': row['response'],
                'created_at': row['created_at']
            })
        
        # Invertir para mostrar del más antiguo al más reciente
        return list(reversed(messages))
    
    @staticmethod
    def delete_history(user_id):
        """Elimina el historial de un usuario"""
        query = "DELETE FROM chatbot_messages WHERE user_id = %s"
        Database.execute_query(query, (user_id,), fetch=False)
    
    @staticmethod
    def get_all_messages(user_id):
        """Obtiene todos los mensajes de un usuario"""
        query = """
        SELECT id, user_id, message, response, created_at
        FROM chatbot_messages
        WHERE user_id = %s
        ORDER BY created_at ASC
        """
        results = Database.execute_query(query, (user_id,), fetch=True)
        
        if not results:
            return []
        
        messages = []
        for row in results:
            messages.append({
                'id': row['id'],
                'user_id': row['user_id'],
                'message': row['message'],
                'response': row['response'],
                'created_at': row['created_at']
            })
        
        return messages
