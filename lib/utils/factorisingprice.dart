import 'package:intl/intl.dart';

String factorisingPrice(int price){
  return NumberFormat("#,##0",'FR_fr').format(price);
}