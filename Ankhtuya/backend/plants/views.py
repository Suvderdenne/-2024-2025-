from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from .services import PlantHealthService

class PlantHealthAssessmentView(APIView):
    def post(self, request):
        """
        Assess plant health from base64 encoded image
        """
        image_base64 = request.data.get('image')
        
        if not image_base64:
            return Response(
                {'error': 'Image data is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        result = PlantHealthService.assess_plant_health(image_base64)
        
        if result['status'] == 'error':
            return Response(
                result,
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
            
        return Response(result, status=status.HTTP_200_OK) 