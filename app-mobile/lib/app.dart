import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/products/products_bloc.dart';
import 'presentation/pages/app_selector_page.dart';

class MakitiApp extends StatelessWidget {
  const MakitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => ProductsBloc()),
      ],
      child: MaterialApp(
        title: 'Makiti Market',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppSelectorPage(),
      ),
    );
  }
}

