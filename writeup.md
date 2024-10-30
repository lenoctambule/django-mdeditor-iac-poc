# django-mdeditor : Lack of Access Control and Unrestricted Upload of File with Dangerous Type on "mdeditor/uploads" view

## Fix

Add Access Control around the view as when using MDTextField within django.admin :

```py

```