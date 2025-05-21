from django.core.exceptions import ObjectDoesNotExist
from .models import Product, Category


class ProductService:

    @staticmethod
    def create_product(name, description, price, stock_quantity, image_url, category_id):
        try:
            Category = Category.objects.get(id=category_id)
            product = Product.objects.create(
                name=name,
                description=description,
                price=price,
                stock_quantity=stock_quantity,
                image_url=image_url,
                category=Category
            )
            return product
        except Category.DoesNotExist:
            raise ValueError("Category not found")

    @staticmethod
    def update_product(product_id, **kwargs):
        try:
            product = Product.objects.get(id=product_id)
            for key, value in kwargs.items():
                if hasattr(product, key):
                    setattr(product, key, value)
            product.save()
            return product
        except Product.DoesNotExist:
            raise ValueError("Product not found")

    @staticmethod
    def delete_product(product_id):
        try:
            product = Product.objects.get(id=product_id)
            product.delete()
            return True
        except Product.DoesNotExist:
            raise ValueError("Product not found")

    @staticmethod
    def get_product(product_id):
        try:
            return Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            raise ValueError("Product not found")

    @staticmethod
    def list_products():
        return Product.objects.all().order_by('-created_at')

    @staticmethod
    def list_products_by_category(category_id):
        return Product.objects.filter(category_id=category_id).order_by('-created_at')
