import 'package:shop_good/features/categorie/data/models/categori_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategorieServices {
  final SupabaseClient _supabase=Supabase.instance.client;
  Future<List<CategoriModel>> getAllCategories()async{
    try{
      final response=await _supabase.from('categories').select('*').order('diplay_order');
      return (response as List).map((json)=>CategoriModel.fromJson(json)).toList();
    }catch(e){
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }
}