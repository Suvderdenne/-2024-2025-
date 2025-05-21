from django.db import migrations

def add_basic_categories(apps, schema_editor):
    Category = apps.get_model('app', 'Category')
    
    categories = [
        {
            'name': 'Цамц',
            'description': 'Бүх төрлийн цамц, энгийн болон зурагтай цамцууд'
        },
        {
            'name': 'Хувцас',
            'description': 'Албан болон энгийн хувцас, цахилгаан товчтой хувцас'
        },
        {
            'name': 'Өмд',
            'description': 'Жинс, өмд болон бусад төрлийн өмд'
        },
        {
            'name': 'Даашинз',
            'description': 'Бүх төрлийн даашинз, энгийн, албан болон үдэшлэгийн даашинз'
        },
        {
            'name': 'Банзай',
            'description': 'Богино, дунд, урт банзай'
        },
        {
            'name': 'Хүрэм',
            'description': 'Бүх улирлын хүрэм, хүрэм болон гадна хувцас'
        },
        {
            'name': 'Ноосон хувцас',
            'description': 'Ноосон хувцас, кардиган болон бусад ноосон хувцас'
        },
        {
            'name': 'Гутлын төрөл',
            'description': 'Бүх төрлийн гутлын төрөл, спорт гутлын төрөл, бүтэн гутлын төрөл болон албан гутлын төрөл'
        },
        {
            'name': 'Дагалдах хэрэгсэл',
            'description': 'Бүс, ороолт, малгай болон бусад загварын дагалдах хэрэгсэл'
        },
        {
            'name': 'Цүнх',
            'description': 'Гар цүнх, арын цүнх болон бусад төрлийн цүнх'
        }
    ]
    
    for category_data in categories:
        Category.objects.get_or_create(
            name=category_data['name'],
            defaults={'description': category_data['description']}
        )

def remove_basic_categories(apps, schema_editor):
    Category = apps.get_model('app', 'Category')
    Category.objects.all().delete()

class Migration(migrations.Migration):
    dependencies = [
        ('app', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(add_basic_categories, remove_basic_categories),
    ]