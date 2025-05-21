from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from django.http import JsonResponse, HttpResponseNotAllowed
from django.views.decorators.csrf import csrf_exempt
from .models import AppUser, Spy, Pack, PackItem, Player, SpyPack
import json, random
from yapnvibev1be.settings import * 

@api_view(['POST'])
def user(request):
    user_id = request.data.get('user_id')
    print('f', user_id)
    if not user_id:
        return sendResponse(2)

    user = AppUser.objects.create(user_id=user_id)
    sp = Spy.objects.create(user=user, players=10, spies=1, timer=2)
    spp = SpyPack.objects.create(user=user, pack_id=1, isown=False)
    return sendResponse(3)

def get_user(data):
    user_id = data.get('user_id')
    return get_object_or_404(AppUser, user_id=user_id)


@csrf_exempt
def get_spy_data(request, user_id):
    user = get_object_or_404(AppUser, user_id=user_id)
    spies = Spy.objects.filter(user=user)
    data = [{
        'id': s.id,
        'players': s.players,
        'spies': s.spies,
        'timer': s.timer,
    } for s in spies]
    return JsonResponse({'spy_data': data})

@csrf_exempt
def spypack(request, user_id):
    user = get_object_or_404(AppUser, user_id=user_id)
    s = SpyPack.objects.filter(user=user).first()
    
    if not s:
        return JsonResponse({'spypack': []})
    
    data = [{
        'user': s.user.user_id,
        'pack_id': s.pack.id,
        'pack_name': s.pack.name,
        'isown': s.isown,
    }]
    
    return JsonResponse({'spypack': data})

@csrf_exempt
def edit_spypack(request, user_id):
    if request.method in ['POST', 'PUT']:
        try:
            data = json.loads(request.body)
            
            # Fetch the SpyPack object associated with the user_id
            spy_pack = get_object_or_404(SpyPack, user__user_id=user_id)

            # Get the Pack instance corresponding to the provided pack ID
            pack_id = data.get('pack')  # Get the pack ID from the request data
            if pack_id:
                pack = get_object_or_404(Pack, id=pack_id)  # Fetch the Pack instance
                spy_pack.pack = pack  # Assign the Pack instance to SpyPack
                
            # Update the 'isown' field
            spy_pack.isown = data.get('isown', spy_pack.isown)
            
            # Save the updated SpyPack instance
            spy_pack.save()

            # Return a success message in JSON format
            return JsonResponse({'message': 'Spy pack updated successfully'})

        except Exception as e:
            # Handle any exceptions and return an error message
            return JsonResponse({'error': str(e)}, status=400)

    # If the request method is not POST or PUT, return an error
    return HttpResponseNotAllowed(['POST', 'PUT'])
@csrf_exempt
def edit_spy(request, spy_id):
    if request.method in ['POST', 'PUT']:
        data = json.loads(request.body)
        spy = get_object_or_404(Spy, id=spy_id)

        spy.players = data.get('players', spy.players)
        spy.spies = data.get('spies', spy.spies)
        spy.timer = data.get('timer', spy.timer)

        spy.save()
        return JsonResponse({'message': 'Spy game updated'})

    return HttpResponseNotAllowed(['POST', 'PUT'])


# --- PACK ---
@csrf_exempt
def get_pack_data(request, user_id):
    user = get_object_or_404(AppUser, user_id=user_id)
    packs = (Pack.objects.filter(user=user) | Pack.objects.filter(user__isnull=True)).distinct()

    data = [{
        'id': p.id,
        'name': p.name,
        'user': p.user.user_id if p.user else None,  # return user_id as string
    } for p in packs]

    return JsonResponse({'pack_data': data})


@csrf_exempt
def add_pack(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user = get_user(data)
        pack = Pack.objects.create(user=user, name=data['name'])
        return JsonResponse({'message': 'Pack added', 'id': pack.id})


@csrf_exempt
def edit_pack(request, pack_id):
    if request.method == 'PUT':  # Change from POST to PUT for updates
        data = json.loads(request.body)
        pack = get_object_or_404(Pack, id=pack_id, user__user_id=data['user_id'])
        pack.name = data['name']
        pack.save()
        return JsonResponse({'message': 'Pack updated'}, status=200)
    return JsonResponse({'error': 'Invalid method'}, status=400)
@csrf_exempt
def delete_pack(request, pack_id):
    if request.method == 'DELETE':
        data = json.loads(request.body)
        pack = get_object_or_404(Pack, id=pack_id, user__user_id=data['user_id'])
        pack.delete()
        return JsonResponse({'message': 'Pack deleted'}, status=200)
    return JsonResponse({'error': 'Invalid method'}, status=400)


# --- PACK ITEM ---
@csrf_exempt
def get_packitem_data(request, pack_id):
    pack = get_object_or_404(Pack, id=pack_id)
    user_id = request.GET.get('user_id')
    user = get_object_or_404(AppUser, user_id=user_id)

    if pack.user != user and pack.user is not None:
        return JsonResponse({'error': 'Unauthorized'}, status=403)

    items = PackItem.objects.filter(pack=pack)
    data = [{
        'id': i.id,
        'itemname': i.itemname,
        'pack': i.pack.name,
        'user': i.pack.user.user_id if i.pack.user else 'global',
        'can_edit': i.pack.user == user
    } for i in items]

    return JsonResponse({'packitem_data': data})


@csrf_exempt
def add_pack_item(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user = get_user(data)
        pack = get_object_or_404(Pack, id=data['pack_id'], user=user)
        item = PackItem.objects.create(itemname=data['itemname'], pack=pack)
        return JsonResponse({'message': 'Pack item added', 'id': item.id})


@csrf_exempt
def delete_pack_item(request, item_id):
    if request.method == 'DELETE':
        data = json.loads(request.body)
        item = get_object_or_404(PackItem, id=item_id)
        user = get_user(data)

        if item.pack.user != user:
            return JsonResponse({'error': 'Unauthorized'}, status=403)

        item.delete()
        return JsonResponse({'message': 'Pack item deleted'})

@csrf_exempt
def playerlist(request, user_id):
    user = get_object_or_404(AppUser, user_id=user_id)
    player = (Player.objects.filter(user=user))

    data = [{
        'id': p.id,
        'name': p.playername,
        'user': p.user.user_id 
    } for p in player]

    return JsonResponse({'pack_data': data})


@csrf_exempt
def add_player(request, user_id):
    if request.method == 'POST':
        data = json.loads(request.body)
        name = data['playername']


        user = get_object_or_404(AppUser, user_id=user_id)
        player = Player.objects.create(user=user, playername=name)
    return JsonResponse({'status': 'success', 'player_id': player.id})


@csrf_exempt
def edit_player(request, player_id):
    if request.method == 'POST':
        data = json.loads(request.body)
        name = data.get('playername')

        try:
            player = Player.objects.get(id=player_id)
            player.playername = name
            player.save()
            return JsonResponse({'status': 'success'})
        except Player.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Player not found'}, status=404)

@csrf_exempt
def delete_player(request, player_id):
    if request.method == 'DELETE':
        try:
            player = Player.objects.get(id=player_id)
            player.delete()
            return JsonResponse({'status': 'deleted'})
        except Player.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Player not found'}, status=404)


@csrf_exempt
def sppc(request, user_id):
    user = get_object_or_404(AppUser, user_id=user_id)
    spy_packs = SpyPack.objects.filter(user=user)  # Query SpyPack related to the user
    
    if not spy_packs:
        return JsonResponse({'spypackitem': []})  # If no SpyPack items exist for the user
    
    # Select a random SpyPack (you can adjust this logic if you want more control)
    spy_pack = random.choice(spy_packs)  # Select one random SpyPack
    
    # Get PackItems related to the selected SpyPack
    pack_items = PackItem.objects.filter(pack=spy_pack.pack)
    
    if not pack_items:
        return JsonResponse({'spypackitem': []})  # If no PackItems are found
    
    # Select a random PackItem
    random_pack_item = random.choice(pack_items)
    
    data = {
        'user': spy_pack.user.user_id,
        'pack_id': spy_pack.pack.id,
        'pack_name': spy_pack.pack.name,
        'pack_item_id': random_pack_item.id,
        'pack_item_name': random_pack_item.itemname,
        'isown': spy_pack.isown,
    }
    
    return JsonResponse({'spypackitem': [data]})