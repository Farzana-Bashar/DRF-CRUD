# Basic installation

```pip3 install django```
```pip3 install djangorestframework```

# DRF-CRUD
``` django-admin startproject crud```

``` python3 -m django startproject DjangoRestApisPostgreSQL```    #alternative, where djangoadmin is not working

```cd crud```

``` python3 manage.py ```

```startapp api```

### create model in models.py

```python3 manage.py makemigrations api```

```python3 manage.py migrate api```

### Make super user
```python3 manage.py createsuperuser```

username = farzana
pass = 12345

### Start project
```python3 manage.py runserver```

### create serializer in serializers.py

### make a third-party app
myapp.py in crud

### create views in views.py

### add path in url.py
