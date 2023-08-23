import copy
import random

from uuid import uuid4

from collections import namedtuple

Product = namedtuple('Product', ['code', 'name', 'price'])

products = [
    Product('A0001', 'Hair Comb', 2.99),
    Product('A0002', 'Toothbrush', 5.99),
    Product('A0003', 'Dental Floss', 0.99),
    Product('A0004', 'Hand Soap', 1.99)
]

seller_ids = ['abc', 'xyz', 'jkq', 'wrp']
customer_ids = [
    "C1000", "C1001", "C1002", "C1003", "C1004", "C1005", "C1006", "C1007", "C1008", "C1009",
    "C1010", "C1011", "C1012", "C1013", "C1014", "C1015", "C1016", "C1017", "C1018", "C1019",
]


def make_order():
    order_id = str(uuid4())
    seller_id = random.choice(seller_ids)
    customer_id = random.choice(customer_ids)
    order_items = []

    available_products = copy.copy(products)
    n_products = random.randint(1, len(products))
    for _ in range(n_products):
        product = random.choice(available_products)
        available_products.remove(product)
        qty = random.randint(1, 10)

        order_items.append({
            'product_name': product.name,
            'product_code': product.code,
            'product_quantity': qty,
            'product_price': product.price
        })

    order = {
        'customer_id': customer_id,
        'seller_id': seller_id,
        'order_id': order_id,
        'order_items': order_items
    }
    return order
