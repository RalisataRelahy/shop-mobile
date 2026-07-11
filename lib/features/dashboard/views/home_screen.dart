import 'package:flutter/material.dart';
import 'package:shop_good/features/categorie/views/categories_list.dart';
import 'package:shop_good/features/combo/views/combo_caroussel.dart';
import 'package:shop_good/features/dashboard/views/widgets/header.dart';
import 'package:shop_good/features/menu/views/menu_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Blanc cassé
      body: SafeArea(
        child: Column(
          children: [
            // Header fixé en haut
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: 10,
              ),
              child: const Header(),
            ),
            
            // Reste du contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      _buildTitle(title: "Nos Combox", onTap: () {}),
                      const ComboCarrousel(),
                      const SizedBox(height: 15),
                      _buildTitle(title: "Nos Catégories", onTap: () {}),
                      const CategoriesList(),
                      const SizedBox(height: 15),
                      const MenuList(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle({required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              "Voir plus",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF34A881),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
