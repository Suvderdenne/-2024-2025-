from django.db import models
    
class Playertype(models.Model):
    eng_name = models.CharField(max_length=40)
    mon_name = models.CharField(max_length=40)

    def __str__(self):
        return self.mon_name

    
class Questionlevel(models.Model):
    eng_name = models.CharField(max_length=40)
    mon_name = models.CharField(max_length=40)
    eng_desc = models.CharField(max_length=300)
    mon_desc = models.CharField(max_length=300)

    def __str__(self):
        return self.mon_name
    
class Dare(models.Model):
    eng_text = models.TextField()
    mon_text = models.TextField()
    image = models.ImageField(upload_to='dare/', blank=True, null=True)
    questionlevel = models.ForeignKey(Questionlevel, on_delete=models.CASCADE)
    playertype = models.ForeignKey(Playertype, on_delete=models.CASCADE)
    def __str__(self):
        return self.mon_text

class Question(models.Model): 
    questionlevel = models.ForeignKey(Questionlevel, on_delete=models.CASCADE)
    playertype = models.ForeignKey(Playertype, on_delete=models.CASCADE)
    eng_text = models.TextField()
    mon_text = models.TextField()
    image = models.ImageField(upload_to='question/', blank=True, null=True)

    def __str__(self):
        return self.mon_text

class Feedback(models.Model):
    comment = models.TextField()

    def __str__(self):
        return self.comment
    


