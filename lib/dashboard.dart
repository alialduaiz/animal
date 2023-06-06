// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class DashBoardScreen extends StatefulWidget {
//
//
//   @override
//   _DashBoardScreenState createState() => _DashBoardScreenState();
// }
//
// class _DashBoardScreenState extends State<DashBoardScreen> {
//   PageController _pageController = PageController();
//   int _pageIndex = 0;
//   late List<Widget> _screens;
//
//
//   GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
//
//   bool singleVendor = false;
//
//
//   @override
//   void initState() {
//     // bool isGuestMode = !Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
//
// /*
//     if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
//       //Provider.of<AuthProvider>(context, listen: false).isLoggedIn() ?
//       // Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context):null;
//       // Provider.of<AuthProvider>(context, listen: false).isLoggedIn() ?
//       // Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context):null;
//       Provider.of<CartProvider>(context, listen: false).uploadToServer(context);
//       Provider.of<CartProvider>(context, listen: false).getCartDataAPI(context);
//       //  Provider.of<CartProvider>(context, listen: false).getCartData();
//     }else {
//       if (isGuestMode) {
//
//       } else {
//         Provider.of<CartProvider>(context, listen: false).getCartData();
//
//       }
//
//     }*/
//     _screens = [
//       HomePage(),
//       //    CategoryPage(),
//       AllCategoryScreen(),
//       CartScreen(),
//       WishListScreen(),
//       //FiltersScreen()
//       Profile()];
//     NetworkInfo.checkConnectivity(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor:AppConstants.textScaleFactior),
//       child: WillPopScope(
//         onWillPop: () async {
//           if (_pageIndex != 0) {
//             _setPage(0);
//             return false;
//           } else {
//             return true;
//           }
//         },
//
//         child: Scaffold(
//           key: _scaffoldKey,
//           bottomNavigationBar: BottomNavigationBar(
//             iconSize :27.0,
//
//
//             fixedColor: Colors.redAccent,
//             unselectedFontSize:14,
//
//             // selectedItemColor: Theme
//             //     .of(context)
//             //     .primaryColor,
//             unselectedItemColor: Theme
//                 .of(context)
//                 .textTheme
//                 .bodyText1
//                 .color,
//
//             showUnselectedLabels: true,
//             currentIndex: _pageIndex,
//             unselectedLabelStyle: robotoRegular.copyWith(fontSize:14,fontWeight: FontWeight.w600,color: Colors.red.withOpacity(0.4)),
//             selectedLabelStyle: robotoBold.copyWith(
//                 color: Colors.red),
//             type: BottomNavigationBarType.fixed,
//             items: _getBottomWidget(singleVendor),
//             onTap: (int index) {
//               _setPage(index);
//             },
//           ),
//           /// here is the drawer
//           // drawer: Drawer(
//           //   child: MoreScreen(),
//           // ),
//           body: PageView.builder(
//             controller: _pageController,
//             itemCount: _screens.length,
//             physics: NeverScrollableScrollPhysics(),
//             itemBuilder: (context, index) {
//               return _screens[index];
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   BottomNavigationBarItem _barItem(String icon, String label, int index) {
//     return BottomNavigationBarItem(
//       icon: Image.asset(icon,
//
//         height: 29, width: 29,
//       ),
//       label: label,
//     );
//   }
//
//   void _setPage(int pageIndex) {
//     setState(() {
//       _pageController.jumpToPage(pageIndex);
//       _pageIndex = pageIndex;
//     });
//   }
//
//
//   List<BottomNavigationBarItem> _getBottomWidget(bool isSingleVendor) {
//     List<BottomNavigationBarItem> _list = [];
//     _list.add(_barItem(_pageIndex==0?Images.new_home_image_filled:Images.new_home_image, getTranslated('home1', context), 0,));
//     _list.add(_barItem(_pageIndex==1 ?Images.new_Categories_image_filled:Images.new_Categories_image, getTranslated('all_category', context), 1));
//
//     _list.add(BottomNavigationBarItem(label: getTranslated('CART', context), icon: Consumer<CartProvider>(builder: (context, value, child) =>Stack(
//         children: <Widget>[
//           Image.asset(_pageIndex==2?Images.new_cart_image_filled:Images.new_cart_image,
//             height: 26, width: 26,
//           ),
//           Provider.of<CartProvider>(context,listen: false).cartList.length.toString()=='0'?SizedBox(): Positioned(top: -0, right: -0,
//             child: Consumer<CartProvider>(builder: (context, cart, child) {
//               return CircleAvatar(radius: 6,
//                 backgroundColor:_pageIndex==2? ColorResources.BLACK: Colors.red,
//                 child: Text(cart.cartList.length.toString(),
//                   style: titilliumSemiBold.copyWith(
//                     color: ColorResources.WHITE,
//                     fontSize: Dimensions
//                         .FONT_SIZE_EXTRA_SMALL,
//                   ),),
//               );
//             }),
//           ),
//
//         ]
//     ) ,),));
//
//     Provider.of<WishListProvider>(context,listen: false).allWishList!=null && Provider.of<AuthProvider>(context, listen: false).isLoggedIn() ? _list.add(BottomNavigationBarItem(
//       label: getTranslated('wishlist', context),
//       icon:  Consumer<WishListProvider>(
//         builder: (context, value, child) =>
//             Stack(
//                 children: <Widget>[
//                   Image.asset(_pageIndex==3?Images.new_wishlist_image_filled:Images.new_wishlist_image,
//                     height: 26, width: 26,
//                   ),
//                   Provider.of<WishListProvider>(context,listen: false).allWishList.length.toString()=='0'?SizedBox(): Positioned(top: -0, right: -0,
//                     child: Consumer<CartProvider>(builder: (context, cart, child) {
//                       return CircleAvatar(radius: 6,
//                         backgroundColor:_pageIndex==3? ColorResources.BLACK: Colors.red,
//                         child: Text( Provider.of<WishListProvider>(context,listen: false).allWishList.length.toString(),
//                           style: titilliumSemiBold.copyWith(
//                             color: ColorResources.WHITE,
//                             fontSize: Dimensions
//                                 .FONT_SIZE_EXTRA_SMALL,
//                           ),),
//                       );
//                     }),
//                   ),
//
//                 ]
//             ),
//
//       ),
//
//     )): _list.add(_barItem(_pageIndex==3?Images.new_wishlist_image_filled:Images.new_wishlist_image, getTranslated('wishlist', context), 3));
//     ;
//
//
//     _list.add(_barItem(_pageIndex==4?Images.new_profile_image_filled :Images.new_profile_image, getTranslated('PROFILE', context), 4));
//     return _list;
//   }
// }