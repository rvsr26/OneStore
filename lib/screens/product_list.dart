import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'product_detail.dart';
import 'wishlist_page.dart';
import 'notification_page.dart';
import 'chatbot_screen.dart';
import 'settings_page.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final _searchCtrl = TextEditingController();

  final stories = [
    {'name': 'All', 'img': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=150&q=80'},
    {'name': 'Clothes', 'img': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=150&q=80'},
    {'name': 'Shoes', 'img': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=150&q=80'},
    {'name': 'Electronics', 'img': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=150&q=80'},
    {'name': 'Accessories', 'img': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=150&q=80'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<ProductProvider>(context, listen: false).loadWishlist(user.uid);
      }
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(onResult: (v) {
          // 🛡️ FIX: Only update state on final result to prevent infinite loop
          if (v.finalResult) {
            setState(() {
              _searchCtrl.text = v.recognizedWords;
              _isListening = false;
            });

            final pp = Provider.of<ProductProvider>(context, listen: false);
            pp.search(v.recognizedWords);
            pp.addToHistory(v.recognizedWords);
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showFilterModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) {
        return Consumer<ProductProvider>(
          builder: (ctx, pp, _) {
            return Container(
              padding: EdgeInsets.all(20),
              height: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sort & Filter", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  SizedBox(height: 20),

                  ListTile(
                    leading: Icon(Icons.sort, color: textColor),
                    title: Text("Price: Low to High", style: TextStyle(color: textColor)),
                    trailing: pp.sortBy == 'Price: Low to High' ? Icon(Icons.check, color: Colors.indigo) : null,
                    onTap: () {
                      pp.sortProducts('Price: Low to High');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.sort_by_alpha, color: textColor),
                    title: Text("Price: High to Low", style: TextStyle(color: textColor)),
                    trailing: pp.sortBy == 'Price: High to Low' ? Icon(Icons.check, color: Colors.indigo) : null,
                    onTap: () {
                      pp.sortProducts('Price: High to Low');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.new_releases, color: textColor),
                    title: Text("Newest First", style: TextStyle(color: textColor)),
                    trailing: pp.sortBy == 'Newest' ? Icon(Icons.check, color: Colors.indigo) : null,
                    onTap: () {
                      pp.sortProducts('Newest');
                      Navigator.pop(context);
                    },
                  ),

                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ Use context.watch/read correctly to avoid rebuild loops
    final pp = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final lang = context.watch<LanguageProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: Icon(Icons.auto_awesome, color: isDark ? Colors.black : Colors.white),
        tooltip: "Ask AI Assistant",
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen())),
      ),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          lang.getText('discover'),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.5
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: textColor),
            onPressed: () => _showFilterModal(context),
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: textColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage())),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: textColor),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage())),
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${cart.totalItems}', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
            ],
          )
        ],
      ),

      drawer: _buildDrawer(context, lang, isDark, textColor),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildSearchBar(pp, lang, isDark, textColor, cardColor),
                if (pp.searchHistory.isNotEmpty) _buildSearchHistory(pp, isDark, textColor),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (_searchCtrl.text.isEmpty && pp.recommendations.isNotEmpty)
                    _buildAiRecommendations(pp, isDark, textColor, cardColor),

                  if (_searchCtrl.text.isEmpty) _buildStoriesSection(pp, isDark, textColor),

                  SizedBox(height: 15),

                  pp.products.isEmpty
                    ? _buildEmptyState(isDark, textColor)
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: pp.products.length,
                          itemBuilder: (c, i) => 
                            _buildProductCard(pp.products[i], context, isDark, textColor, cardColor),
                        ),
                      ),

                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------ WIDGETS --------------------------

  Widget _buildSearchBar(ProductProvider pp, LanguageProvider lang, bool isDark, Color textColor, Color cardColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: lang.getText('search'),
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[800]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (v) => pp.search(v),
              onSubmitted: (v) => pp.addToHistory(v),
            ),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: _listen,
          child: Container(
            height: 50, width: 50,
            decoration: BoxDecoration(
              color: _isListening ? Colors.redAccent : (isDark ? Colors.white : Colors.black),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
            ),
            child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Colors.white : (isDark ? Colors.black : Colors.white)),
          ),
        )
      ],
    );
  }

  Widget _buildSearchHistory(ProductProvider pp, bool isDark, Color textColor) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(top: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: pp.searchHistory.map((h) => Container(
          margin: EdgeInsets.only(right: 8),
          child: InputChip(
            label: Text(h),
            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
            shape: StadiumBorder(side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.shade400)),
            labelStyle: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
            onDeleted: () => pp.clearHistory(),
            deleteIcon: Icon(Icons.close, size: 14, color: textColor),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAiRecommendations(ProductProvider pp, bool isDark, Color textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[700], size: 20),
              SizedBox(width: 5),
              Text("Picked for You", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
            ],
          ),
        ),
        Container(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: pp.recommendations.length,
            itemBuilder: (context, index) {
              final p = pp.recommendations[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 15, bottom: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          child: CachedNetworkImage(imageUrl: p.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                            Text("\$${p.price}", style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesSection(ProductProvider pp, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Collections",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)
          ),
        ),
        Container(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16),
            itemCount: stories.length,
            itemBuilder: (c, i) {
              bool isSelected = pp.selectedCategory == stories[i]['name'];
              return GestureDetector(
                onTap: () => pp.filterByCategory(stories[i]['name']!),
                child: Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Container(
                        width: 70, height: 70,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? textColor : Colors.grey.shade300, 
                            width: isSelected ? 3 : 2
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: stories[i]['img']!, 
                            fit: BoxFit.cover,
                            placeholder: (c, u) => Container(color: Colors.grey[200]),
                            errorWidget: (c, u, e) => Icon(Icons.error, color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        stories[i]['name']!,
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, 
                          color: isSelected ? textColor : Colors.grey[600]
                        )
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic p, BuildContext context, bool isDark, Color textColor, Color cardColor) {
    final cart = context.read<CartProvider>(); 
    final pp = Provider.of<ProductProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    final isInCart = cart.items.any((item) => item.product.id == p.id);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: p.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: CachedNetworkImage(
                        imageUrl: p.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (c, u) => Container(color: Colors.grey[100]),
                        errorWidget: (c, u, e) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8, top: 8,
                    child: GestureDetector(
                      onTap: () {
                        pp.toggleFavorite(p.id, user?.uid);
                      },
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: isDark ? Colors.black54 : Colors.white,
                        child: Icon(
                          p.isFavorite ? Icons.favorite : Icons.favorite_border, 
                          size: 16,
                          color: p.isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textColor)
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${p.price}', 
                        style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w900, fontSize: 17)
                      ),
                      InkWell(
                        onTap: () {
                          if (isInCart) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
                          } else {
                            String defaultVariant = p.variants.isNotEmpty ? p.variants.values.first.first : 'Default';
                            cart.addProduct(p, defaultVariant);
                            
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Added ${p.title} to Cart"),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
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
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isInCart ? Colors.green : (isDark ? Colors.white : Colors.black),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Icon(
                            isInCart ? Icons.check : Icons.add, 
                            size: 20,
                            color: isInCart ? Colors.white : (isDark ? Colors.black : Colors.white)
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text("No Products Found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          Text("Try searching for something else.", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, LanguageProvider lang, bool isDark, Color textColor) {
    final user = Provider.of<AuthProvider>(context).user;
    final theme = Provider.of<ThemeProvider>(context);

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.black),
            accountName: Text(user?.displayName ?? "Guest", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? "Sign in to access full features"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? Icon(Icons.person, color: Colors.black) : null,
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: textColor),
            title: Text(lang.getText('profile'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()))
          ),
          ListTile(
            leading: Icon(Icons.favorite_outline, color: textColor),
            title: Text(lang.getText('wishlist'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistPage()))
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: textColor),
            title: Text("Settings", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()))
          ),
          Divider(color: Colors.grey[700]),
          ListTile(
            leading: Icon(Icons.brightness_6_outlined, color: textColor),
            title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (v) => theme.toggleTheme(v),
              activeColor: Colors.indigoAccent,
            ),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[400]),
            title: Text("Logout", style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold)),
            onTap: () => Provider.of<AuthProvider>(context, listen: false).signOut()
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}