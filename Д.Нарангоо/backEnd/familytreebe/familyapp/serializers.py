from django.contrib.auth.hashers import make_password, check_password
from rest_framework import serializers
from .models import Person, Place, Uye, UrgiinOvog, User
from django.core.files.storage import default_storage

# 🟢 UrgiinOvog Serializer
class UrgiinOvogSerializer(serializers.Serializer):
    class Meta:
        model = UrgiinOvog
        fields = '__all__'

    def create(self, validated_data):
        return UrgiinOvog(**validated_data).save()
    
class UyeSerializer(serializers.Serializer):    
    class Meta:
        model = Uye
        fields = '__all__'

    def create(self, validated_data):
        return Uye(**validated_data).save()
class RelationshipSerializer(serializers.Serializer):
    from_person_id = serializers.CharField()
    to_person_id = serializers.CharField()
    relationship_type = serializers.ChoiceField(choices=[
        "ЭЦЭГ", "ЭХ", "ХҮҮХЭД", "АХ","ЭГЧ","ДҮҮ", "ГЭР БҮЛ", "ӨВӨӨ", "ЭМЭЭ", "ТӨРСӨН", "ХАМААРНА", "ХАРЬЯЛАГДДАГ", "БҮРТГЭСЭН", "ЗАСВАРЛАСАН"
    ])
    
# 🟢 Place Serializer
class PlaceSerializer(serializers.Serializer):
    class Meta:
        model = Place
        fields = '__all__'

    def create(self, validated_data):
        return Place(**validated_data).save()
# 🟢 User Serializer
class UserSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    repassword = serializers.CharField(write_only=True)  # Added confirm password
    element_id = serializers.CharField(read_only=True)

    def validate(self, data):
        """Ensure password and repassword match."""
        if data['password'] != data['repassword']:
            raise serializers.ValidationError({"repassword": "Нууц үг таарахгүй байна!"})
        return data

    def create(self, validated_data):
        """Remove repassword field before saving."""
        validated_data.pop('repassword')  
        validated_data['password'] = make_password(validated_data['password'])  # Hash password
        user = User(**validated_data)
        user.save()  
        return user
    def update(self, instance, validated_data):
        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        
        if 'password' in validated_data:
            instance.password = make_password(validated_data['password'])  # Always hash updated password
        instance.save()
        return instance
    
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')

        try:
            user = User.nodes.get(username=username)
        except User.DoesNotExist:
            raise serializers.ValidationError("Хэрэглэгч олдсонгүй!")

        if not check_password(password, user.password):
            raise serializers.ValidationError("Нууц үг буруу байна!")

        data['user'] = user
        return data

# 🟢 Person Serializer
class PersonSerializer(serializers.Serializer):
    name = serializers.CharField()
    lastname = serializers.CharField(required=False)
    gender = serializers.ChoiceField(choices=["Эр", "Эм"])
    birthdate = serializers.DateField()
    diedate = serializers.DateField(required=False, allow_null=True)
    image_url = serializers.CharField(required=False)
    biography = serializers.CharField(required=False)
    element_id = serializers.CharField(read_only=True)

    # 🔹 Custom representations
    generation = serializers.SerializerMethodField()
    birthplace = serializers.SerializerMethodField()
    urgiinovog = serializers.SerializerMethodField()

    def get_generation(self, obj):
        try:
            uye = obj.generation.single()
            return {"uyname": uye.uyname, "level": uye.level}
        except:
            return None

    def get_birthplace(self, obj):
        try:
            place = obj.born_in.single()
            return {"name": place.name, "country": place.country}
        except:
            return None

    def get_urgiinovog(self, obj):
        try:
            clan = obj.urgiinovog.single()
            return {"urgiinovog": clan.urgiinovog}
        except:
            return None

    def create(self, validated_data):
        person = Person(**validated_data)
        person.save()
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            user = User.nodes.get(username=request.user.username)
            person.created_by.connect(user)
        return person

    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
class FamilyMemberListSerializer(serializers.Serializer):
    person_id = serializers.CharField()

    def to_representation(self, instance):
        person = Person.nodes.get(element_id=instance["person_id"])
        data = {
            "ЭЦЭГ": [PersonSerializer(p).data for p in person.father.all()],
            "ЭХ": [PersonSerializer(p).data for p in person.mother.all()],
            "ХҮҮХЭД": [PersonSerializer(p).data for p in person.children.all()],
            "АХ": [PersonSerializer(p).data for p in person.brothers.all()],
            "ЭГЧ": [PersonSerializer(p).data for p in person.sisters.all()],
            "ДҮҮ": [PersonSerializer(p).data for p in person.youngsiblings.all()],
            "ГЭР БҮЛ": [PersonSerializer(p).data for p in person.spouse.all()],
            "ӨВӨӨ": [PersonSerializer(p).data for p in person.grandfather.all()],
            "ЭМЭЭ": [PersonSerializer(p).data for p in person.grandmother.all()],
        }
        return data
class FamilyMemberAddSerializer(serializers.Serializer):
    from_person_id = serializers.CharField()
    relationship_type = serializers.ChoiceField(choices=[
        "ЭЦЭГ", "ЭХ", "ХҮҮХЭД", "АХ", "ЭГЧ", "ДҮҮ", "ГЭР БҮЛ", "ӨВӨӨ", "ЭМЭЭ"
    ])
    name = serializers.CharField()
    lastname = serializers.CharField(required=False)
    gender = serializers.ChoiceField(choices=["Эр", "Эм"])
    birthdate = serializers.DateField()
    diedate = serializers.DateField(required=False, allow_null=True)
    biography = serializers.CharField(required=False)
    
    # 🔹 New fields
    uye_id = serializers.CharField(required=False)
    place_id = serializers.CharField(required=False)
    urgiinovog_id = serializers.CharField(required=False)

    def create(self, validated_data):
        from_person_id = validated_data.pop("from_person_id")
        relationship_type = validated_data.pop("relationship_type")

        # Optional relationship fields
        uye_id = validated_data.pop("uye_id", None)
        place_id = validated_data.pop("place_id", None)
        urgiinovog_id = validated_data.pop("urgiinovog_id", None)

        try:
            # First get the user
            user = User.nodes.get(uid=from_person_id)
            # Then get their associated person
            from_person = next(iter(user.created_people.all()), None)
            if not from_person:
                raise serializers.ValidationError({"from_person_id": "No person found for this user"})
        except User.DoesNotExist:
            raise serializers.ValidationError({"from_person_id": "User not found"})

        new_person = Person(**validated_data)
        new_person.save()
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            user = User.nodes.get(username=request.user.username)
            new_person.created_by.connect(user)

        # Family relationship
        # Map relationship types to their corresponding methods
        relationship_map = {
            "ЭЦЭГ": "father",
            "ЭХ": "mother",
            "ХҮҮХЭД": "children",
            "АХ": "brothers",
            "ЭГЧ": "sisters",
            "ДҮҮ": "youngsiblings",
            "ГЭР БҮЛ": "spouse",
            "ӨВӨӨ": "grandfather",
            "ЭМЭЭ": "grandmother"
        }

        rel_method_name = relationship_map.get(relationship_type)
        if rel_method_name:
            rel_method = getattr(from_person, rel_method_name)
            rel_method.connect(new_person)
        else:
            raise serializers.ValidationError("Invalid relationship type")

        # Generation (Үе)
        if uye_id:
            try:
                uye_node = Uye.nodes.get(uid=uye_id)
                new_person.generation.connect(uye_node)
            except Uye.DoesNotExist:
                raise serializers.ValidationError({"uye_uid": "Invalid Uye UID"})
        # Birthplace
        if place_id:
            try:
                place = Place.nodes.get(uid=place_id)
                new_person.born_in.connect(place)
            except Place.DoesNotExist:
                raise serializers.ValidationError({"place_id": "Invalid Place UID"})
        # Clan (Ургийн овог)
        if urgiinovog_id:
            try:
                clan = UrgiinOvog.nodes.get(uid=urgiinovog_id)
                new_person.urgiinovog.connect(clan)
            except UrgiinOvog.DoesNotExist:
                raise serializers.ValidationError({"urgiinovog_id": "Invalid UrgiinOvog UID"})
        return new_person

class SimplePersonSerializer(serializers.Serializer):
    name = serializers.CharField(required=True)
    lastname = serializers.CharField(required=False, allow_blank=True)
    gender = serializers.ChoiceField(choices=["Эр", "Эм"])
    birthdate = serializers.DateField(required=True)
    diedate = serializers.DateField(required=False, allow_null=True)
    biography = serializers.CharField(required=False, allow_blank=True)
    birthplace = serializers.JSONField(required=False, allow_null=True)
    urgiinovog_id = serializers.CharField(required=False, allow_null=True)
    uye_id = serializers.CharField(required=False, allow_null=True)

    def create(self, validated_data):
        # Extract relationship fields that shouldn't be passed to Person constructor
        urgiinovog_id = validated_data.pop('urgiinovog_id', None)
        birthplace = validated_data.pop('birthplace', None)
        uye_id = validated_data.pop('uye_id', None)
        
        # Create the person
        person = Person(**validated_data)
        person.save()
        
        # Handle relationships if provided
        if urgiinovog_id:
            try:
                clan = UrgiinOvog.nodes.get(uid=urgiinovog_id)
                person.urgiinovog.connect(clan)
            except UrgiinOvog.DoesNotExist:
                pass  # Silently ignore if urgiinovog not found
                
        if birthplace and isinstance(birthplace, dict) and 'uid' in birthplace:
            try:
                place = Place.nodes.get(uid=birthplace['uid'])
                person.born_in.connect(place)
            except Place.DoesNotExist:
                pass  # Silently ignore if place not found
                
        if uye_id:
            try:
                uye = Uye.nodes.get(uid=uye_id)
                person.generation.connect(uye)
            except Uye.DoesNotExist:
                pass  # Silently ignore if uye not found
                
        return person

    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
    
    def get_urgiinovog(self, obj):
        try:
            clan = obj.urgiinovog.single()
            return {"urgiinovog": clan.urgiinovog}
        except:
            return None
        
    def get_birthplace(self, obj):
        try:
            place = obj.born_in.single()
            return {"name": place.name, "country": place.country}
        except:
            return None