from django.db import models
import mdeditor
import mdeditor.fields

class Test(models.Model):
    text = mdeditor.fields.MDTextField()
    image = models.ImageField()