from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Playertype, Questionlevel, Question, Dare
import json
from django.db.models import Q


@csrf_exempt
def playertype(request):
    data = [
        {
            "id": p.id,
            "eng_name": p.eng_name.capitalize(),
            "mon_name": p.mon_name.capitalize(),
        }
        for p in Playertype.objects.all()
    ]
    
    return JsonResponse({"playertypes": data}, safe=False)


@csrf_exempt
def questionlevel(request):
    data = [
        {
            "id": p.id,
            "eng_name": p.eng_name.capitalize(),
            "mon_name": p.mon_name.capitalize(),
            "eng_desc": p.eng_desc.capitalize(),
            "mon_desc": p.mon_desc.capitalize(),
        }
        for p in Questionlevel.objects.all()
    ]
    
    return JsonResponse({"questionlevels": data}, safe=False)

@csrf_exempt
def question(request):
    if request.method == 'POST':
        jsons = json.loads(request.body)
        playertype = jsons.get('playertypee')
        level = jsons.get('questionlevel')
        
        if not level or not playertype:
            return JsonResponse({"m": "obso"}, status=400)  # Return error if level or type is missing
        
        questions = Question.objects.filter(
            Q(questionlevel__mon_name=level) | Q(questionlevel__eng_name=level),
            Q(playertype__mon_name=playertype) | Q(playertype__eng_name=playertype)
        )
        
        if not questions.exists():
            return JsonResponse({"m": "No questions found for the provided type and level."}, status=404)
        
        data = [{
            "id": que.id, 
            "eng_text": que.eng_text ,
            "mon_text": que.mon_text
        } for que in questions]
        
        return JsonResponse({"questions": data}, safe=False)


@csrf_exempt
def dare(request):
    if request.method == 'POST':
        jsons = json.loads(request.body)
        playertype = jsons.get('playertypee')
        level = jsons.get('questionlevel')
        
        if not level or not playertype:
            return JsonResponse({"m": "obso"}, status=400)  # Return error if level or type is missing
        
        dares = Dare.objects.filter(
            Q(questionlevel__mon_name=level) | Q(questionlevel__eng_name=level),
            Q(playertype__mon_name=playertype) | Q(playertype__eng_name=playertype)
        )
        
        if not dares.exists():
            return JsonResponse({"m": "No dares found for the provided type and level."}, status=404)
        
        data = [{
            "id": que.id, 
            "eng_text": que.eng_text,
            "mon_text":que.mon_text
        } for que in dares]
        
        return JsonResponse({"dares": data}, safe=False)
    
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
