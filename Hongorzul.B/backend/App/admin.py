from django.contrib import admin
from .models import Customer, Branch, Role, Worker, Service, CalendarEvent, ServiceCategory, Made
from django.contrib.auth.admin import UserAdmin

# Registering models with the admin site
# admin.site.register(Customer)
admin.site.register(Branch)
admin.site.register(Role)
admin.site.register(Worker)
admin.site.register(ServiceCategory)
admin.site.register(Service)
admin.site.register(CalendarEvent)
admin.site.register(Made)




class CustomerAdmin(UserAdmin):
    model = Customer
    list_display = ('cemail', 'cname', 'cphone', 'is_staff')
    search_fields = ('cemail', 'cname')
    ordering = ('customer_id',)
    fieldsets = (
        (None, {'fields': ('cemail', 'password')}),
        ('Personal Info', {'fields': ('cname', 'cphone', 'cimage')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('cemail', 'cname', 'cphone', 'password1', 'password2'),
        }),
    )

admin.site.register(Customer, CustomerAdmin)
