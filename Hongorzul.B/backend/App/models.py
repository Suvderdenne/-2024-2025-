from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin

class CustomerManager(BaseUserManager):
    def create_user(self, cemail, cname, cphone, password=None, **extra_fields):
        if not cemail:
            raise ValueError("The Email field is required")
        
        email = self.normalize_email(cemail)
        customer = self.model(
            cemail=email,
            cname=cname,
            cphone=cphone,
            **extra_fields
        )
        customer.set_password(password)
        customer.save(using=self._db)
        return customer

    def create_superuser(self, cemail, cname, cphone, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(cemail, cname, cphone, password, **extra_fields)


class Customer(AbstractBaseUser, PermissionsMixin):
    customer_id = models.AutoField(primary_key=True)
    cname = models.CharField(max_length=255)
    cemail = models.EmailField(unique=True)
    cphone = models.CharField(max_length=15)
    cimage = models.ImageField(upload_to='customer_images/', null=True, blank=True)
    token = models.CharField(max_length=255, null=True, blank=True)
    blacklist = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    # Required fields for AbstractBaseUser
    USERNAME_FIELD = 'cemail'
    REQUIRED_FIELDS = ['cname', 'cphone']

    objects = CustomerManager()

    class Meta:
        db_table = 't_customer'

    def __str__(self):
        return self.cname



# Branch Model

class Branch(models.Model):
    branch_id = models.AutoField(primary_key=True)
    bname = models.CharField(max_length=255, verbose_name="Branch Name")
    blocation = models.CharField(max_length=255, verbose_name="Branch Location")
    bimage = models.ImageField(upload_to='media/images', null=True, blank=True, verbose_name="Branch Image")  # 👈 Add this line

    class Meta:
        db_table = "t_branch"
        verbose_name = "Branch"
        verbose_name_plural = "Branches"

    def __str__(self):
        return self.bname



# Role Model
class Role(models.Model):
    role_id = models.AutoField(primary_key=True)
    role_name = models.CharField(max_length=255, unique=True, verbose_name="Role Name")

    class Meta:
        db_table = "t_role"
        verbose_name = "Role"
        verbose_name_plural = "Roles"

    def __str__(self):
        return self.role_name


# Worker Model
class Worker(models.Model):
    worker_id = models.AutoField(primary_key=True)
    wfirst = models.CharField(max_length=255, verbose_name="Worker First Name")
    wname = models.CharField(max_length=255, verbose_name="Worker Last Name")
    wphone = models.CharField(max_length=15, unique=True, verbose_name="Worker Phone")
    role = models.ForeignKey('Role', on_delete=models.CASCADE, related_name="workers", verbose_name="Role")
    branch = models.ForeignKey('Branch', null=True, blank=True, on_delete=models.SET_NULL, related_name="workers", verbose_name="Branch")
    worker_image = models.ImageField(upload_to='worker_images/', null=True, blank=True, verbose_name="Worker Image")

    class Meta:
        db_table = "t_worker"
        verbose_name = "Worker"
        verbose_name_plural = "Workers"

    def __str__(self):
        return f"{self.wfirst} {self.wname}"


# Service Category Model
class ServiceCategory(models.Model):
    category_id = models.AutoField(primary_key=True)
    cname = models.CharField(max_length=255, unique=True, verbose_name="Category Name")
    cdescription = models.TextField(null=True, blank=True, verbose_name="Category Description")

    class Meta:
        db_table = "t_service_category"
        verbose_name = "Service Category"
        verbose_name_plural = "Service Categories"
        ordering = ['cname']

    def __str__(self):
        return self.cname


# Service Model
class Service(models.Model):
    service_id = models.AutoField(primary_key=True)
    sname = models.CharField(max_length=255, verbose_name="Service Name")
    sprice = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Service Price")
    sduration = models.CharField(max_length=255, unique=True, verbose_name="Duration")
    simage = models.ImageField(upload_to='service_images/', null=True, blank=True, verbose_name="Service Image")
    scomment = models.TextField(null=True, blank=True, verbose_name="Comment")
    category = models.ForeignKey(ServiceCategory, on_delete=models.SET_NULL, null=True, blank=True, related_name="services", verbose_name="Category")

    class Meta:
        db_table = "t_service"
        verbose_name = "Service"
        verbose_name_plural = "Services"
        ordering = ['sname']

    def __str__(self):
        return self.sname

    
class CalendarEvent(models.Model):
    event_id = models.AutoField(primary_key=True)
    description = models.TextField(verbose_name="Event Description", blank=True, null=True)
    start_time = models.DateTimeField(verbose_name="Start Time", default=timezone.now)
    end_time = models.DateTimeField(verbose_name="End Time", default=timezone.now)
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name="events", verbose_name="Service")
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name="events", verbose_name="Customer")
    worker = models.ForeignKey(Worker, on_delete=models.CASCADE, related_name="events", verbose_name="Worker", null=True, blank=True)
    branch = models.ForeignKey(Branch, on_delete=models.CASCADE, related_name="events", verbose_name="Branch")

    
    class Meta:
        db_table = "t_calendar_event"
        verbose_name = "Calendar Event"
        verbose_name_plural = "Calendar Events"
        ordering = ['start_time']

    def __str__(self):
        return self.description or f"Event on {self.start_time.strftime('%Y-%m-%d %H:%M')}"
    

class Made(models.Model):
    made_id = models.AutoField(primary_key=True)
    made_image = models.ImageField(upload_to='made_images/')
    made_worker = models.ForeignKey(Worker, on_delete=models.CASCADE)
    made_service_category = models.ForeignKey(ServiceCategory, on_delete=models.CASCADE)
    comment = models.TextField(blank=True, null=True)

    class Meta:
        db_table = "t_made"
        verbose_name = "Made Work"
        verbose_name_plural = "Made Works"
        ordering = ['made_id']  # or any other field you'd like to sort by

    def __str__(self):
        return f"Made by {self.made_worker} in {self.made_service_category}"


