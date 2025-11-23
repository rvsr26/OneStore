import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // 1. PRODUCT CATALOG (100 Items)
  // ---------------------------------------------------------------------------
  final List<Product> _items = [
    // ==========================
    // CATEGORY: CLOTHES (25 Items)
    // ==========================
    Product(
      id: 'c1',
      title: 'Classic White Tee',
      description: 'Premium 100% cotton t-shirt. Breathable and perfect for any season.',
      price: 19.99,
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L', 'XL'], 'Color': ['White']},
      stock: 50,
      gallery: ['https://images.unsplash.com/photo-1583743814966-8936f5b7be1a'],
    ),
    Product(
      id: 'c2',
      title: 'Oversized Black Hoodie',
      description: 'Heavyweight fleece hoodie with a relaxed fit. Kangaroo pocket.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['M', 'L', 'XL'], 'Color': ['Black', 'Charcoal']},
      stock: 30,
      gallery: ['https://images.unsplash.com/photo-1556821840-3a63f95609a7'],
    ),
    Product(
      id: 'c3',
      title: 'Slim Fit Denim Jeans',
      description: 'Dark wash denim with a hint of stretch for comfort.',
      price: 59.99,
      imageUrl: 'https://images.unsplash.com/photo-1542272617-08f086320482?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['30', '32', '34', '36'], 'Length': ['30', '32']},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 'c4',
      title: 'Floral Summer Dress',
      description: 'Lightweight rayon dress with a vintage floral print.',
      price: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['XS', 'S', 'M', 'L']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 'c5',
      title: 'Beige Trench Coat',
      description: 'Classic double-breasted trench coat. Water-resistant.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L'], 'Color': ['Beige', 'Black']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 'c6',
      title: 'Graphic Streetwear Tee',
      description: 'Urban style t-shirt with bold back print.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L', 'XL']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'c7',
      title: 'Merino Wool Sweater',
      description: 'Soft, warm, and lightweight merino wool pullover.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1620799140408-ed5341cd2431?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L'], 'Color': ['Navy', 'Grey']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 'c8',
      title: 'Athletic Gym Shorts',
      description: 'Moisture-wicking fabric perfect for high-intensity workouts.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L', 'XL']},
      stock: 45,
      gallery: [],
    ),
    Product(
      id: 'c9',
      title: 'Plaid Flannel Shirt',
      description: 'Cozy flannel shirt, great for layering.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1507680434567-5739c8a9782b?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L', 'XL'], 'Color': ['Red', 'Green']},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 'c10',
      title: 'Leather Biker Jacket',
      description: 'Genuine leather jacket with silver hardware.',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['M', 'L', 'XL']},
      stock: 10,
      gallery: [],
    ),
    Product(
      id: 'c11',
      title: 'Cargo Pants',
      description: 'Utility trousers with multiple pockets. Rugged durability.',
      price: 54.99,
      imageUrl: 'https://images.unsplash.com/photo-1517438476312-10d79c077509?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['30', '32', '34', '36']},
      stock: 28,
      gallery: [],
    ),
    Product(
      id: 'c12',
      title: 'Silk Evening Gown',
      description: 'Elegant floor-length silk dress for formal occasions.',
      price: 249.99,
      imageUrl: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['XS', 'S', 'M']},
      stock: 5,
      gallery: [],
    ),
    Product(
      id: 'c13',
      title: 'Yoga Leggings',
      description: 'High-waisted, squat-proof leggings with side pockets.',
      price: 44.99,
      imageUrl: 'https://images.unsplash.com/photo-1506619216599-9d16d0903dfd?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['XS', 'S', 'M', 'L']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'c14',
      title: 'Linen Button Down',
      description: 'Breathable linen shirt, essential for beach vacations.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['M', 'L', 'XL'], 'Color': ['White', 'Sky Blue']},
      stock: 32,
      gallery: [],
    ),
    Product(
      id: 'c15',
      title: 'Puffer Jacket',
      description: 'Insulated winter jacket to keep you warm in sub-zero temps.',
      price: 119.99,
      imageUrl: 'https://images.unsplash.com/photo-1545558014-8692077e9b5c?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['M', 'L', 'XL'], 'Color': ['Black', 'Orange']},
      stock: 22,
      gallery: [],
    ),
    Product(
      id: 'c16',
      title: 'Corduroy Shacket',
      description: 'Hybrid shirt-jacket made from soft corduroy fabric.',
      price: 64.99,
      imageUrl: 'https://images.unsplash.com/photo-1582552938357-32b906df40cb?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L']},
      stock: 18,
      gallery: [],
    ),
    Product(
      id: 'c17',
      title: 'Pleated Midi Skirt',
      description: 'Metallic finish pleated skirt, great for parties.',
      price: 45.99,
      imageUrl: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 'c18',
      title: 'Crop Top Set',
      description: 'Matching crop top and shorts set for summer.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['XS', 'S', 'M']},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 'c19',
      title: 'Business Suit Blazer',
      description: 'Tailored fit blazer for the professional look.',
      price: 149.99,
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4729d7?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['38', '40', '42', '44']},
      stock: 12,
      gallery: [],
    ),
    Product(
      id: 'c20',
      title: 'Chino Shorts',
      description: 'Smart casual shorts, perfect for golf or brunch.',
      price: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['30', '32', '34']},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 'c21',
      title: 'Thermal Undertop',
      description: 'Base layer for extreme cold weather.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L', 'XL']},
      stock: 50,
      gallery: [],
    ),
    Product(
      id: 'c22',
      title: 'Varsity Jacket',
      description: 'Classic collegiate style jacket with letterman patch.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1559551409-dadc959f76b8?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['M', 'L', 'XL']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 'c23',
      title: 'Maxi Boho Skirt',
      description: 'Flowy bohemian skirt with elastic waist.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1565214975484-3cfa9e56f914?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L']},
      stock: 28,
      gallery: [],
    ),
    Product(
      id: 'c24',
      title: 'Tracksuit Set',
      description: 'Full zip jacket and matching joggers. Comfortable casual.',
      price: 69.99,
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['S', 'M', 'L', 'XL']},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 'c25',
      title: 'Polo Shirt',
      description: 'Pique cotton polo with embroidered logo.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1625910515337-1616109fed41?auto=format&fit=crop&w=600&q=80',
      category: 'Clothes',
      variants: {'Size': ['M', 'L', 'XL', 'XXL']},
      stock: 55,
      gallery: [],
    ),

    // ==========================
    // CATEGORY: SHOES (25 Items)
    // ==========================
    Product(
      id: 's1',
      title: 'Urban Low Sneakers',
      description: 'Minimalist white sneakers. Versatile and comfortable.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['7', '8', '9', '10', '11']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 's2',
      title: 'Pro Running Shoes',
      description: 'High-performance running shoes with foam cushioning.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10', '11', '12'], 'Color': ['Red', 'Blue']},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 's3',
      title: 'Chelsea Boots',
      description: 'Suede chelsea boots in tan. Stylish and rugged.',
      price: 99.99,
      imageUrl: 'https://images.unsplash.com/photo-1638984849699-20d1a87657c9?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10', '11']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 's4',
      title: 'High-Top Basketball',
      description: 'Retro style high-tops with ankle support.',
      price: 149.99,
      imageUrl: 'https://images.unsplash.com/photo-1579338559194-a162d19bf842?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['9', '10', '11', '12', '13']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 's5',
      title: 'Classic Loafers',
      description: 'Leather penny loafers. Office ready.',
      price: 119.99,
      imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['7', '8', '9', '10'], 'Color': ['Black', 'Brown']},
      stock: 22,
      gallery: [],
    ),
    Product(
      id: 's6',
      title: 'Hiking Boots',
      description: 'Waterproof trail boots with deep tread.',
      price: 139.99,
      imageUrl: 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10', '11']},
      stock: 18,
      gallery: [],
    ),
    Product(
      id: 's7',
      title: 'Canvas Slip-Ons',
      description: 'Easy wear slip-on shoes. Great for skating.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1463100099107-aa0980c362e6?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['6', '7', '8', '9', '10', '11']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 's8',
      title: 'Stiletto Heels',
      description: '4-inch pump heels in patent black.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['5', '6', '7', '8', '9']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 's9',
      title: 'Summer Sandals',
      description: 'Leather strappy sandals with cork sole.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['6', '7', '8', '9']},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 's10',
      title: 'Oxford Dress Shoes',
      description: 'Formal lace-up shoes with cap toe.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1478146059778-26028b07395a?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10', '11', '12']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 's11',
      title: 'Soccer Cleats',
      description: 'Lightweight cleats for firm ground.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1511886929837-354d827aae26?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['7', '8', '9', '10']},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 's12',
      title: 'Winter Snow Boots',
      description: 'Faux fur lined boots, temperature rated to -20C.',
      price: 109.99,
      imageUrl: 'https://images.unsplash.com/photo-1606890658317-7d14490b76fd?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['6', '7', '8', '9', '10']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 's13',
      title: 'Platform Sneakers',
      description: 'Chunky sole sneakers for added height.',
      price: 69.99,
      imageUrl: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['6', '7', '8']},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 's14',
      title: 'Espadrilles',
      description: 'Canvas shoes with jute rope sole. Vacation vibes.',
      price: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1574756297869-c12149e5d62d?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['6', '7', '8', '9']},
      stock: 45,
      gallery: [],
    ),
    Product(
      id: 's15',
      title: 'Combat Boots',
      description: 'Heavy duty leather lace-up boots.',
      price: 119.99,
      imageUrl: 'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['7', '8', '9', '10']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 's16',
      title: 'Ballet Flats',
      description: 'Soft leather flats, extremely comfortable.',
      price: 59.99,
      imageUrl: 'https://images.unsplash.com/photo-1560343090-f0409e92791a?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['5', '6', '7', '8']},
      stock: 50,
      gallery: [],
    ),
    Product(
      id: 's17',
      title: 'Moccasins',
      description: 'Suede slippers with fleece lining.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1610524597562-3835b8c8c04c?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10', '11']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 's18',
      title: 'Wedge Sandals',
      description: 'High wedge heel with ankle strap.',
      price: 54.99,
      imageUrl: 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['6', '7', '8', '9']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 's19',
      title: 'Skate Shoes',
      description: 'Padded collar and durable sole for skating.',
      price: 64.99,
      imageUrl: 'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10', '11']},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 's20',
      title: 'Flip Flops',
      description: 'Rubber flip flops for the beach.',
      price: 14.99,
      imageUrl: 'https://images.unsplash.com/photo-1602546636692-2f0e021b019a?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['7', '8', '9', '10', '11']},
      stock: 100,
      gallery: [],
    ),
    Product(
      id: 's21',
      title: 'Monk Straps',
      description: 'Double buckle leather dress shoes.',
      price: 139.99,
      imageUrl: 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 's22',
      title: 'Safety Boots',
      description: 'Steel toe work boots.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1575936123452-b67c3203c357?auto=format&fit=crop&w=600&q=80', // Placeholder for boot
      category: 'Shoes',
      variants: {'Size': ['9', '10', '11', '12']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 's23',
      title: 'Mary Janes',
      description: 'Classic strap shoes with glossy finish.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&q=80', // Reused heel img
      category: 'Shoes',
      variants: {'Size': ['5', '6', '7', '8']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 's24',
      title: 'Driving Loafers',
      description: 'Soft leather with rubber grip sole.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['8', '9', '10']},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 's25',
      title: 'Clogs',
      description: 'Comfortable rubber clogs, easy to clean.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?auto=format&fit=crop&w=600&q=80',
      category: 'Shoes',
      variants: {'Size': ['7', '8', '9', '10']},
      stock: 80,
      gallery: [],
    ),

    // ==========================
    // CATEGORY: ELECTRONICS (25 Items)
    // ==========================
    Product(
      id: 'e1',
      title: 'Wireless NC Headphones',
      description: 'Over-ear headphones with active noise cancellation.',
      price: 299.99,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['Black', 'Silver']},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 'e2',
      title: 'Smart Watch Series 5',
      description: 'Fitness tracker, heart rate monitor, and GPS.',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Band Color': ['Black', 'Pink', 'White']},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 'e3',
      title: 'Pro Laptop 13"',
      description: 'Ultra-slim laptop with M1 chip. 16GB RAM.',
      price: 1299.99,
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Storage': ['256GB', '512GB']},
      stock: 10,
      gallery: [],
    ),
    Product(
      id: 'e4',
      title: '4K Action Camera',
      description: 'Waterproof camera for extreme sports recording.',
      price: 349.99,
      imageUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Bundle': ['Basic', 'Adventure Kit']},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 'e5',
      title: 'Bluetooth Speaker',
      description: 'Portable 360-degree sound speaker.',
      price: 79.99,
      imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['Blue', 'Red', 'Black']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'e6',
      title: 'Gaming Console',
      description: 'Next-gen console with 8K support.',
      price: 499.99,
      imageUrl: 'https://images.unsplash.com/photo-1486401899868-0e435ed85128?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Edition': ['Digital', 'Disc']},
      stock: 5,
      gallery: [],
    ),
    Product(
      id: 'e7',
      title: 'Mechanical Keyboard',
      description: 'RGB backlit keyboard with blue switches.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Switch': ['Blue', 'Red', 'Brown']},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 'e8',
      title: 'Wireless Mouse',
      description: 'Ergonomic mouse with long battery life.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['Black', 'Grey']},
      stock: 50,
      gallery: [],
    ),
    Product(
      id: 'e9',
      title: 'Tablet Pro 11"',
      description: 'High resolution display, perfect for digital art.',
      price: 799.99,
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Connectivity': ['WiFi', 'Cellular']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 'e10',
      title: 'Drone with Camera',
      description: 'Foldable drone with 4K video and 30min flight time.',
      price: 459.99,
      imageUrl: 'https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Batteries': ['1 Pack', '3 Pack']},
      stock: 12,
      gallery: [],
    ),
    Product(
      id: 'e11',
      title: 'Smartphone X',
      description: 'Latest flagship phone with triple lens camera.',
      price: 999.99,
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Storage': ['128GB', '256GB']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 'e12',
      title: 'DSLR Camera Body',
      description: '24MP Full frame DSLR for professionals.',
      price: 1499.99,
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {},
      stock: 8,
      gallery: [],
    ),
    Product(
      id: 'e13',
      title: 'Wireless Earbuds',
      description: 'True wireless earbuds with charging case.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['White', 'Black']},
      stock: 70,
      gallery: [],
    ),
    Product(
      id: 'e14',
      title: 'Gaming Monitor 144Hz',
      description: '27-inch curved monitor with 1ms response time.',
      price: 249.99,
      imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {},
      stock: 18,
      gallery: [],
    ),
    Product(
      id: 'e15',
      title: 'Smart Thermostat',
      description: 'WiFi enabled thermostat to control home temp.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1567606404-e849b2722a13?auto=format&fit=crop&w=600&q=80', // Placeholder tech
      category: 'Electronics',
      variants: {},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 'e16',
      title: 'External SSD 1TB',
      description: 'Rugged portable solid state drive. Fast transfer.',
      price: 119.99,
      imageUrl: 'https://images.unsplash.com/photo-1597872252165-4827c47d0d1e?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['Black', 'Blue']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'e17',
      title: 'Streaming Stick',
      description: 'Plug into TV to stream 4K content.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {},
      stock: 100,
      gallery: [],
    ),
    Product(
      id: 'e18',
      title: 'VR Headset',
      description: 'Standalone virtual reality system.',
      price: 299.99,
      imageUrl: 'https://images.unsplash.com/photo-1622979135225-d2ba269fb1bd?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Storage': ['128GB', '256GB']},
      stock: 10,
      gallery: [],
    ),
    Product(
      id: 'e19',
      title: 'Smart Bulb Kit',
      description: 'Pack of 4 color changing smart bulbs.',
      price: 59.99,
      imageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {},
      stock: 45,
      gallery: [],
    ),
    Product(
      id: 'e20',
      title: 'E-Reader',
      description: 'Glare-free display for reading books.',
      price: 119.99,
      imageUrl: 'https://images.unsplash.com/photo-1592496001020-d31bd830651f?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['Black', 'White']},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 'e21',
      title: 'Power Bank 20000mAh',
      description: 'Fast charging portable battery pack.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1609592424607-6a9539a545ce?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {},
      stock: 80,
      gallery: [],
    ),
    Product(
      id: 'e22',
      title: 'USB-C Hub',
      description: '7-in-1 adapter for laptops.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1615128756172-9b78685db5c4?auto=format&fit=crop&w=600&q=80', // Tech placeholder
      category: 'Electronics',
      variants: {},
      stock: 55,
      gallery: [],
    ),
    Product(
      id: 'e23',
      title: 'Instant Photo Printer',
      description: 'Print photos directly from your smartphone.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {'Color': ['White', 'Pink']},
      stock: 22,
      gallery: [],
    ),
    Product(
      id: 'e24',
      title: 'WiFi Router 6',
      description: 'High speed gigabit router for gaming.',
      price: 159.99,
      imageUrl: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=600&q=80', // Tech placeholder
      category: 'Electronics',
      variants: {},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 'e25',
      title: 'Home Security Cam',
      description: '1080p indoor camera with night vision.',
      price: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1558002038-10914cbaeb70?auto=format&fit=crop&w=600&q=80',
      category: 'Electronics',
      variants: {},
      stock: 40,
      gallery: [],
    ),

    // ==========================
    // CATEGORY: ACCESSORIES (25 Items)
    // ==========================
    Product(
      id: 'a1',
      title: 'Leather Crossbody Bag',
      description: 'Full grain leather bag with brass hardware.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Brown', 'Black']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 'a2',
      title: 'Aviator Sunglasses',
      description: 'Classic gold frame with polarized lenses.',
      price: 89.99,
      imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Lens': ['Green', 'Black']},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 'a3',
      title: 'Gold Chain Necklace',
      description: '18k gold plated dainty chain.',
      price: 49.99,
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-17488fbbcd75?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {},
      stock: 50,
      gallery: [],
    ),
    Product(
      id: 'a4',
      title: 'Leather Wallet',
      description: 'Slim bi-fold wallet with RFID blocking.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Tan', 'Black']},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'a5',
      title: 'Beanie Hat',
      description: 'Knit beanie, essential for winter.',
      price: 19.99,
      imageUrl: 'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Grey', 'Red', 'Yellow']},
      stock: 100,
      gallery: [],
    ),
    Product(
      id: 'a6',
      title: 'Designer Belt',
      description: 'Genuine leather belt with statement buckle.',
      price: 159.99,
      imageUrl: 'https://images.unsplash.com/photo-1624222247344-550fb60583dc?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Size': ['S', 'M', 'L']},
      stock: 20,
      gallery: [],
    ),
    Product(
      id: 'a7',
      title: 'Silk Scarf',
      description: 'Printed silk scarf. Can be worn on neck or bag.',
      price: 45.99,
      imageUrl: 'https://images.unsplash.com/photo-1584030373081-f37b7bb4fa8e?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 'a8',
      title: 'Baseball Cap',
      description: 'Cotton twill cap with adjustable strap.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Black', 'Navy', 'White']},
      stock: 80,
      gallery: [],
    ),
    Product(
      id: 'a9',
      title: 'Silver Ring Set',
      description: 'Set of 3 stackable sterling silver rings.',
      price: 34.99,
      imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Size': ['6', '7', '8']},
      stock: 45,
      gallery: [],
    ),
    Product(
      id: 'a10',
      title: 'Canvas Backpack',
      description: 'Durable backpack with laptop compartment.',
      price: 69.99,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Green', 'Black']},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 'a11',
      title: 'Wristwatch Analog',
      description: 'Minimalist quartz watch with leather strap.',
      price: 109.99,
      imageUrl: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {},
      stock: 25,
      gallery: [],
    ),
    Product(
      id: 'a12',
      title: 'Hoop Earrings',
      description: 'Large gold-tone hoop earrings.',
      price: 14.99,
      imageUrl: 'https://images.unsplash.com/photo-1630019852942-f89202989a51?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'a13',
      title: 'Tote Bag',
      description: 'Large canvas tote, perfect for groceries or beach.',
      price: 19.99,
      imageUrl: 'https://images.unsplash.com/photo-1597484662317-c9252d308f45?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {},
      stock: 90,
      gallery: [],
    ),
    Product(
      id: 'a14',
      title: 'Bow Tie',
      description: 'Silk bow tie for formal events.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1596364822770-2b56b2d0337b?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Black', 'Red']},
      stock: 40,
      gallery: [],
    ),
    Product(
      id: 'a15',
      title: 'Travel Suitcase',
      description: 'Hard shell carry-on luggage with wheels.',
      price: 149.99,
      imageUrl: 'https://images.unsplash.com/photo-1565026057447-bc936cb9e7b5?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['Silver', 'Black']},
      stock: 15,
      gallery: [],
    ),
    Product(
      id: 'a16',
      title: 'Pearl Necklace',
      description: 'Freshwater pearl strand.',
      price: 199.99,
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-17488fbbcd75?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {},
      stock: 10,
      gallery: [],
    ),
    Product(
      id: 'a17',
      title: 'Bucket Hat',
      description: 'Trendy 90s style bucket hat.',
      price: 22.99,
      imageUrl: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Color': ['White', 'Black']},
      stock: 55,
      gallery: [],
    ),
    Product(
      id: 'a18',
      title: 'Cufflinks',
      description: 'Stainless steel cufflinks.',
      price: 39.99,
      imageUrl: 'https://images.unsplash.com/photo-1616359782573-16773c231758?auto=format&fit=crop&w=600&q=80', // Placeholder
      category: 'Accessories',
      variants: {},
      stock: 30,
      gallery: [],
    ),
    Product(
      id: 'a19',
      title: 'Phone Case',
      description: 'Protective silicone case.',
      price: 14.99,
      imageUrl: 'https://images.unsplash.com/photo-1586105251261-72a756497a11?auto=format&fit=crop&w=600&q=80',
      category: 'Accessories',
      variants: {'Model': ['Pro', 'Max'], 'Color': ['Red', 'Blue']},
      stock: 100,
      gallery: [],
    ),
    Product(
      id: 'a20',
      title: 'Key Holder',
      description: 'Leather key organizer.',
      price: 24.99,
      imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=600&q=80', // Wallet/Leather placeholder
      category: 'Accessories',
      variants: {},
      stock: 50,
      gallery: [],
    ),
    Product(
      id: 'a21',
      title: 'Sports Headband',
      description: 'Sweat absorbing headband.',
      price: 9.99,
      imageUrl: 'https://images.unsplash.com/photo-1543332144-1c1104268234?auto=format&fit=crop&w=600&q=80', // Placeholder
      category: 'Accessories',
      variants: {},
      stock: 80,
      gallery: [],
    ),
    Product(
      id: 'a22',
      title: 'Ankle Bracelet',
      description: 'Gold chain for ankle.',
      price: 29.99,
      imageUrl: 'https://images.unsplash.com/photo-1599643478518-17488fbbcd75?auto=format&fit=crop&w=600&q=80', // Chain placeholder
      category: 'Accessories',
      variants: {},
      stock: 35,
      gallery: [],
    ),
    Product(
      id: 'a23',
      title: 'Makeup Bag',
      description: 'Travel cosmetic pouch.',
      price: 19.99,
      imageUrl: 'https://images.unsplash.com/photo-1597484662317-c9252d308f45?auto=format&fit=crop&w=600&q=80', // Bag placeholder
      category: 'Accessories',
      variants: {},
      stock: 60,
      gallery: [],
    ),
    Product(
      id: 'a24',
      title: 'Hair Clips',
      description: 'Set of pearl hair clips.',
      price: 12.99,
      imageUrl: 'https://images.unsplash.com/photo-1588849538562-8b8b5533459e?auto=format&fit=crop&w=600&q=80', // Placeholder
      category: 'Accessories',
      variants: {},
      stock: 70,
      gallery: [],
    ),
    Product(
      id: 'a25',
      title: 'Pocket Square',
      description: 'Patterned pocket square.',
      price: 15.99,
      imageUrl: 'https://images.unsplash.com/photo-1596364822770-2b56b2d0337b?auto=format&fit=crop&w=600&q=80', // Tie placeholder
      category: 'Accessories',
      variants: {},
      stock: 40,
      gallery: [],
    ),
  ];

  // ---------------------------------------------------------------------------
  // 2. STATE VARIABLES
  // ---------------------------------------------------------------------------
  List<Product> _filteredItems = [];
  List<Product> _recommendations = [];
  Map<String, double> _userCategoryScores = {};
  List<String> _aiMemory = [];

  String _userPersona = "New User";
  String _currentMood = "Neutral";

  List<String> _searchHistory = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Newest';

  // 🛡️ CRASH PREVENTION: Last Viewed Tracker
  // Prevents the loop if a widget calls logProductView inside build()
  String? _lastLoggedProductId;
  DateTime? _lastLoggedTime;

  Timer? _searchDebounce;

  ProductProvider() {
    _filteredItems = [..._items];

    // Initial Recommendation Generation
    Future.microtask(() => _generateRecommendations(notify: false));

    // Load search history silently
    Future.delayed(const Duration(milliseconds: 300), () {
      _loadHistory(silent: true);
    });
  }

  // ---------------------------------------------------------------------------
  // 3. GETTERS
  // ---------------------------------------------------------------------------
  List<Product> get products => _filteredItems;
  List<Product> get favorites => _items.where((p) => p.isFavorite).toList();
  List<Product> get recommendations => _recommendations;
  List<String> get aiMemory => _aiMemory;

  List<String> get categories => ['All', 'Clothes', 'Shoes', 'Electronics', 'Accessories'];
  List<String> get searchHistory => _searchHistory;
  String get selectedCategory => _selectedCategory;
  String get userPersona => _userPersona;
  String get currentMood => _currentMood;
  String get sortBy => _sortBy;

  // Feature: Get Related Products (Same category, excluding current)
  List<Product> getRelatedProducts(Product current) {
    return _items.where((p) => p.category == current.category && p.id != current.id).toList();
  }

  // ---------------------------------------------------------------------------
  // 4. AI ACTIONS 
  // ---------------------------------------------------------------------------
  void logProductView(Product p) {
    // 🛡️ CRASH FIX: Debounce View Logging
    // If we just logged this product less than 2 seconds ago, ignore it.
    // This stops infinite loops if this function is called in a build method.
    if (_lastLoggedProductId == p.id &&
        _lastLoggedTime != null &&
        DateTime.now().difference(_lastLoggedTime!).inSeconds < 2) {
      return;
    }

    _lastLoggedProductId = p.id;
    _lastLoggedTime = DateTime.now();

    _userCategoryScores.update(p.category, (v) => v + 1.0, ifAbsent: () => 1.0);

    // Persona Logic
    if ((_userCategoryScores['Electronics'] ?? 0) > 3) _userPersona = "Tech Geek";
    if ((_userCategoryScores['Clothes'] ?? 0) > 3) _userPersona = "Fashionista";
    if ((_userCategoryScores['Shoes'] ?? 0) > 3) _userPersona = "Sneakerhead";

    var moodData = AIService.analyzeUserMood(
      _userCategoryScores.map((k, v) => MapEntry(k, v.toInt())),
    );

    _currentMood = moodData['mood'];
    _aiMemory.add("Viewed: ${p.title}");

    // Refresh recommendations safely
    Future.microtask(() => _generateRecommendations(notify: true));
  }

  void addChatToMemory(String message) {
    if (message.trim().isNotEmpty) {
      _aiMemory.add("User said: $message");
      // Optional: Don't notify listeners here unless you are displaying memory in UI
    }
  }

  // ---------------------------------------------------------------------------
  // 5. AI RECOMMENDATIONS
  // ---------------------------------------------------------------------------
  void _generateRecommendations({bool notify = false}) {
    _recommendations = AIService.getPersonalizedRecommendations(
      _items,
      _userCategoryScores,
    );
    if (notify) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 6. SEARCH + FILTER + SORT
  // ---------------------------------------------------------------------------
  void search(String query) {
    if (_searchQuery == query) return; // Optimization
    _searchQuery = query;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
      notifyListeners();
    });
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void sortProducts(String sort) {
    _sortBy = sort;
    _applyFilters();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 7. WISHLIST SYNC
  // ---------------------------------------------------------------------------
  Future<void> loadWishlist(String userId, {bool silent = false}) async {
    if (userId.isEmpty) return;

    try {
      List<String> wishlistIds = await FirestoreService().fetchWishlist(userId);

      bool changed = false;
      for (var p in _items) {
        if (p.isFavorite != wishlistIds.contains(p.id)) {
          p.isFavorite = wishlistIds.contains(p.id);
          changed = true;
        }
      }

      if (!silent && changed) notifyListeners();
    } catch (e) {
      debugPrint("Error loading wishlist: $e");
    }
  }

  void toggleFavorite(String productId, String? userId) {
    final index = _items.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    _items[index].isFavorite = !_items[index].isFavorite;
    notifyListeners();

    if (userId != null && userId.isNotEmpty) {
      FirestoreService().toggleWishlist(
        userId,
        productId,
        _items[index].isFavorite,
      );
    }

    _aiMemory.add(
      _items[index].isFavorite
          ? "Favorite: ${_items[index].title}"
          : "Unfavorite: ${_items[index].title}",
    );
  }

  // ---------------------------------------------------------------------------
  // 8. SEARCH HISTORY
  // ---------------------------------------------------------------------------
  Future<void> _loadHistory({bool silent = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('searchHistory') ?? [];
    if (!silent) notifyListeners();
  }

  void addToHistory(String term) async {
    if (term.trim().isEmpty) return;

    _searchHistory.remove(term);
    _searchHistory.insert(0, term);

    if (_searchHistory.length > 5) _searchHistory.removeLast();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);

    notifyListeners();
  }

  void clearHistory() async {
    _searchHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 9. FILTER ENGINE
  // ---------------------------------------------------------------------------
  void _applyFilters() {
    var temp = _items.where((p) {
      final matchCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;

      final matchSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();

    // Sorting
    if (_sortBy == 'Price: Low to High') {
      temp.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      temp.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Newest') {
      // Assuming higher ID means newer if no date field, or just keep original order
      // If you add a 'dateAdded' field to Product, sort by that here.
    }

    _filteredItems = temp;
  }
}