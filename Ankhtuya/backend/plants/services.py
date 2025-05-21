import base64
import requests
from django.conf import settings
from typing import Dict, Any, Optional

class PlantHealthService:
    API_KEY = "PZ0jYqmVTJMgDG7myP2pMNzU1XAY2iRXkQClfxuqxVmmKIbZBN"
    API_URL = "https://api.plant.id/v2/health_assessment"

    @staticmethod
    def assess_plant_health(image_base64: str) -> Dict[str, Any]:
        """
        Assess plant health using Plant.id API
        
        Args:
            image_base64 (str): Base64 encoded image string
            
        Returns:
            Dict[str, Any]: Response containing plant health assessment
        """
        try:
            payload = {
                "api_key": PlantHealthService.API_KEY,
                "images": [image_base64],
                "modifiers": ["similar_images"],
                "plant_language": "en",
                "disease_details": ["description", "treatment", "classification"]
            }

            headers = {"Content-Type": "application/json"}

            response = requests.post(
                PlantHealthService.API_URL,
                headers=headers,
                json=payload
            )

            if response.status_code == 200:
                data = response.json()
                health_assessment = data.get('health_assessment', {})
                diseases = health_assessment.get('diseases', [])

                if diseases:
                    return {
                        'status': 'diseased',
                        'diseases': [{
                            'name': disease.get('name'),
                            'probability': disease.get('probability'),
                            'description': disease.get('description'),
                            'treatment': disease.get('treatment', {})
                        } for disease in diseases]
                    }
                else:
                    return {
                        'status': 'healthy',
                        'message': 'The plant appears to be healthy!'
                    }
            else:
                return {
                    'status': 'error',
                    'message': f'API request failed with status code: {response.status_code}'
                }

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Error assessing plant health: {str(e)}'
            } 