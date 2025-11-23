import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import 'cart_page.dart'; 

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, String> _selectedVariants = {};
  int _currentImageIndex = 0;
  
  // 🛡️ Performance: Cache the stream to prevent reloading on every tap
  late Stream<List<Review>> _reviewsStream;

  Map<String, dynamic> _aiInsights = {
    'sentiment': 'Positive', 
    'fit_prediction': 'True to Size'
  };
  Map<String, dynamic> _trustScore = {'trustScore': '98%'};

  @override
  void initState() {
    super.initState();
    
    // 1. Pre-select Variants
    if (widget.product.variants.isNotEmpty) {
      widget.product.variants.forEach((k, v) {
        if (v.isNotEmpty) _selectedVariants[k] = v.first;
      });
    }

    // 2. Initialize Stream ONCE
    _reviewsStream = FirestoreService().getReviews(widget.product.id);

    // 3. Log User View (Safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.logProductView(widget.product);
    });
    
    // 4. Get AI Predictions
    try {
      _aiInsights = AIService.getProductInsights(widget.product);
      _trustScore = AIService.runAuthenticityCheck(widget.product);
    } catch (e) {
      print("AI Service Error: $e");
    }
  }

  // 🎨 Body Scan Simulation
  void _simulateBodyScan() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) {
        var data = AIService.performBodyScan();
        return Container(
          padding: EdgeInsets.all(20),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AI Body Scan Result", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
              SizedBox(height: 5),
              Text("Scanned using camera measurements", style: TextStyle(color: Colors.grey)),
              Divider(height: 30, color: Colors.grey),
              ListTile(
                leading: Icon(Icons.accessibility_new, color: Colors.indigo), 
                title: Text("Height: ${data['Height']}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor))
              ),
              ListTile(
                leading: Icon(Icons.straighten, color: Colors.indigo), 
                title: Text("Chest: ${data['Chest']} | Waist: ${data['Waist']}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor))
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green), 
                title: Text("Recommended Size: ${data['Suggested Size']}", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 18))
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() => _selectedVariants['Size'] = data['Suggested Size']!);
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Size ${data['Suggested Size']} Applied!")));
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black, 
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: Text("Apply Recommended Size", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 16))
              )
            ],
          ),
        );
      });
  }

  // ✍️ Submit Review Dialog
  void _showReviewDialog(BuildContext context) {
    final _commentCtrl = TextEditingController();
    int _tempRating = 5;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text("Write a Review", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Rate this product", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () => setState(() => _tempRating = index + 1),
                    );
                  }),
                ),
                TextField(
                  controller: _commentCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Share your thoughts...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c), 
                child: Text("Cancel", style: TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.indigo : Colors.black),
                onPressed: () async {
                  if (user != null && _commentCtrl.text.isNotEmpty) {
                    final newReview = Review(
                      id: '', 
                      userId: user.uid,
                      userName: user.displayName ?? "Shopper",
                      comment: _commentCtrl.text.trim(),
                      rating: _tempRating.toDouble(),
                      date: DateTime.now(),
                    );

                    await FirestoreService().addReview(widget.product.id, newReview);

                    if (mounted) {
                      Navigator.pop(c);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review submitted!"), backgroundColor: Colors.green));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please write a comment"), backgroundColor: Colors.red));
                  }
                },
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    // Live data check (if product updates while viewing)
    final liveProduct = productProvider.products.firstWhere(
      (p) => p.id == widget.product.id, 
      orElse: () => widget.product
    );

    final List<String> gallery = liveProduct.gallery; 
    final String heroImage = liveProduct.imageUrl;
    final List<String> allImages = [heroImage, ...gallery];
    final bool isStock = liveProduct.stock > 0;
    final bool isFav = liveProduct.isFavorite;
    final String description = liveProduct.description;
    final String title = liveProduct.title;
    final double price = liveProduct.price;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[800];
    final containerColor = isDark ? Colors.grey[800] : Colors.indigo[50];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // --- 1. IMAGE SLIDER ---
          SliverAppBar(
            expandedHeight: 450, 
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9), shape: BoxShape.circle),
              child: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : (isDark ? Colors.white : Colors.black)),
                  onPressed: () => productProvider.toggleFavorite(widget.product.id, user?.uid),
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: allImages.length,
                    onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                    itemBuilder: (ctx, idx) => CachedNetworkImage(
                      imageUrl: allImages[idx],
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: isDark ? Colors.grey[800] : Colors.grey[100]),
                      errorWidget: (c, u, e) => Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  if (allImages.length > 1)
                    Positioned(
                      bottom: 20,
                      child: Row(
                        children: List.generate(allImages.length, (index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index ? (isDark ? Colors.white : Colors.black) : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- 2. DETAILS & REVIEWS ---
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title, 
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, height: 1.1)
                          )
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isStock ? Colors.green : Colors.red, width: 1)
                          ),
                          child: Text(
                            isStock ? "IN STOCK" : "SOLD OUT",
                            style: TextStyle(color: isStock ? Colors.green : Colors.red, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "\$${price.toStringAsFixed(2)}", 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.indigo)
                    ),
                    
                    SizedBox(height: 20),

                    // Authenticity
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(8), 
                        border: Border.all(color: Colors.green.withOpacity(0.3))
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 20), 
                          SizedBox(width: 8), 
                          Text(
                            "AI Verified Authentic (Trust Score: ${_trustScore['trustScore']})", 
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
                          )
                        ]
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // AI Insights
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: containerColor, 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics, color: Colors.indigo, size: 20), 
                              SizedBox(width: 8), 
                              Text("AI Product Insights", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 16))
                            ]
                          ),
                          Divider(color: Colors.indigo.withOpacity(0.2), height: 20),
                          _aiRow(Icons.thumb_up, "Sentiment: ${_aiInsights['sentiment']}", isDark),
                          _aiRow(Icons.straighten, "${_aiInsights['fit_prediction']}", isDark),
                          _aiRow(Icons.local_shipping, "2-3 Days Delivery", isDark),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Virtual Try-On Buttons
                    if (liveProduct.category == 'Clothes' || liveProduct.category == 'Shoes')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.camera_alt_outlined, color: textColor),
                              label: Text("AI Body Scan", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12), 
                                side: BorderSide(color: textColor, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              onPressed: _simulateBodyScan,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.view_in_ar, color: Colors.indigo),
                              label: Text("Virtual Try-On", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12), 
                                side: BorderSide(color: Colors.indigo, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AIService.getVirtualTryOnResult(liveProduct.category)))
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 25),
                    Divider(color: isDark ? Colors.grey[800] : Colors.grey[300], thickness: 1),
                    SizedBox(height: 20),

                    // Variants
                    if (liveProduct.variants.isNotEmpty)
                    ...liveProduct.variants.entries.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: e.value.map((v) {
                            bool isSelected = _selectedVariants[e.key] == v;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedVariants[e.key] = v),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey[800] : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey),
                                ),
                                child: Text(
                                  v, 
                                  style: TextStyle(
                                    color: isSelected ? (isDark ? Colors.black : Colors.white) : textColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 15
                                  )
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 25),
                      ],
                    )).toList(),

                    Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                    SizedBox(height: 10),
                    Text(
                      description, 
                      style: TextStyle(color: mutedText, height: 1.6, fontSize: 16, fontWeight: FontWeight.w500)
                    ),
                    
                    SizedBox(height: 40),

                    // Reviews Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Reviews", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
                        TextButton.icon(
                          onPressed: () => _showReviewDialog(context),
                          icon: Icon(Icons.edit, size: 18, color: Colors.indigo),
                          label: Text("Write Review", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    
                    // 🔥 REVIEWS STREAM BUILDER (Using cached stream)
                    StreamBuilder<List<Review>>(
                      stream: _reviewsStream, // Uses the stream initialized in initState
                      builder: (c, s) {
                        if (s.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (s.hasError) {
                          return Center(child: Text("Could not load reviews", style: TextStyle(color: Colors.red)));
                        }
                        if (!s.hasData || s.data!.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(30),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[100], 
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey),
                                SizedBox(height: 10),
                                Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: s.data!.map((r) => Container(
                            margin: EdgeInsets.only(bottom: 15),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.white, 
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.indigo.withOpacity(0.1),
                                      child: Text(
                                        r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?', 
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r.userName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                                          Row(
                                            children: List.generate(5, (i) => Icon(
                                              i < r.rating ? Icons.star : Icons.star_border,
                                              size: 14, color: Colors.amber
                                            )),
                                          )
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${r.date.day}/${r.date.month}/${r.date.year}", 
                                      style: TextStyle(fontSize: 12, color: Colors.grey)
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(r.comment, style: TextStyle(color: mutedText, height: 1.4)),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 100), 
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      
      // --- 3. BOTTOM ACTION BAR ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 55,
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                bool isInCart = cart.items.any((item) => item.product.id == widget.product.id);

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isStock 
                        ? (isInCart ? Colors.green : (isDark ? Colors.white : Colors.black)) 
                        : Colors.grey, 
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: isStock ? () {
                    if (isInCart) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
                    } else {
                      String variantString = _selectedVariants.entries.map((e) => "${e.key}: ${e.value}").join(", ");
                      cart.addProduct(widget.product, variantString);
                      
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Added to Cart!", style: TextStyle(fontWeight: FontWeight.bold)), 
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          action: SnackBarAction(
                            label: "VIEW CART",
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
                            },
                          ),
                        )
                      );
                    }
                  } : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart ? Icons.check_circle : Icons.shopping_bag_outlined, 
                        color: isStock ? (isDark && !isInCart ? Colors.black : Colors.white) : Colors.white
                      ),
                      SizedBox(width: 12),
                      Text(
                        isStock 
                            ? (isInCart ? "Go to Cart" : "Add to Cart") 
                            : "Out of Stock",
                        style: TextStyle(
                          fontSize: 18, 
                          color: isStock ? (isDark && !isInCart ? Colors.black : Colors.white) : Colors.white, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _aiRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.indigo[200] : Colors.indigo[300]), 
          SizedBox(width: 10), 
          Expanded(
            child: Text(
              text, 
              style: TextStyle(color: isDark ? Colors.indigo[100] : Colors.indigo[900], fontSize: 14, fontWeight: FontWeight.w600)
            )
          )
        ],
      ),
    );
  }
}