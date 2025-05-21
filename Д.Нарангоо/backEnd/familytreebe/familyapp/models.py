from neomodel import StructuredNode, StructuredRel, StringProperty, DateProperty, IntegerProperty, RelationshipTo, RelationshipFrom, UniqueIdProperty, DateTimeProperty

# -- MARRIAGE RELATIONSHIP --
class MarriageRel(StructuredRel):
    date = DateProperty()  # Marriage date

# -- CLAN --
class UrgiinOvog(StructuredNode):
    uid = UniqueIdProperty()
    urgiinovog = StringProperty(required=True)  # Clan name (e.g., Боржигон, Чонос)
    def get_element_id(self):
        return self.element_id

# -- GENERATIO --
class Uye(StructuredNode):
    uid = UniqueIdProperty()
    uyname = StringProperty(required=True)
    level = IntegerProperty(required=True)
    # Relationships
    persons = RelationshipFrom('Person', 'ХАРЪЯАЛАГДАНА')
    def get_element_id(self):
        return self.element_id

# -- PLACE --
class Place(StructuredNode):
    uid = UniqueIdProperty()
    name = StringProperty()
    country = StringProperty()
    def get_element_id(self):
        return self.element_id

# -- PERSON --
class Person(StructuredNode):
    uid = UniqueIdProperty()
    lastname = StringProperty()
    name = StringProperty(required=True)
    gender = StringProperty(choices={"Эр": "Эр", "Эм": "Эм"}, default="Эр")
    birthdate = DateProperty(required=True)
    diedate = DateProperty(default=None)
    image_url = StringProperty()
    biography = StringProperty()  # Instead of намтар
    createdate = DateTimeProperty(default_now=True)
    modifydate = DateTimeProperty(default_now=True)
     # 🔸 Explicit Family Relationships
    father = RelationshipTo('Person', 'ЭЦЭГ')       # Father
    mother = RelationshipTo('Person', 'ЭХ')         # Mother
    children = RelationshipTo('Person', 'ХҮҮХЭД')   # Children

    brothers = RelationshipTo('Person', 'АХ')       # Brother
    sisters = RelationshipTo('Person', 'ЭГЧ')        # Sister
    youngsiblings = RelationshipTo('Person', 'ДҮҮ')       # Children

    grandfather = RelationshipTo('Person', 'ӨВӨӨ')   # Grandfather
    grandmother = RelationshipTo('Person', 'ЭМЭЭ')   # Grandmother

    # Spouse (one-to-one or many-to-one with optional marriage date)
    spouse = RelationshipTo('Person', 'ГЭР БҮЛ', model=MarriageRel)

    # Birthplace
    born_in = RelationshipTo('Place', 'ТӨРСӨН')

    # Generation (Үе) and Clan (Ургийн овог)
    generation = RelationshipTo('Uye', 'ХАМААРНА')
    urgiinovog = RelationshipTo('UrgiinOvog', 'ХАРЬЯЛАГДДАГ')

    # Audit info
    created_by = RelationshipFrom('User', 'БҮРТГЭСЭН')
    modified_by = RelationshipFrom('User', 'ЗАСВАРЛАСАН')
    def get_element_id(self):
        return self.element_id

# -- USER --
class User(StructuredNode):
    
    uid = UniqueIdProperty()  
    username = StringProperty(required=True)
    email = StringProperty(required=True)
    password = StringProperty(required=True)
    token = StringProperty()
    # Relationships
    created_people = RelationshipTo('Person', 'БҮРТГЭСЭН')  # Users can create multiple people
    family_trees = RelationshipTo('UserFamilyTree', 'HAS_FAMILY_TREE')  # User can have one or more family trees
    @property
    def is_authenticated(self):
        return True
    def get_element_id(self):
        return self.element_id 

# -- USER FAMILY TREE --
class UserFamilyTree(StructuredNode):
    uid = UniqueIdProperty()
    root_person = RelationshipTo('Person', 'MANAGES', cardinality=1)
    user = RelationshipFrom('User', 'HAS_FAMILY_TREE', cardinality=1)
    name = StringProperty()
    description = StringProperty()
    def get_element_id(self):
        return self.element_id
