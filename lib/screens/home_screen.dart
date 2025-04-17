import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import '../cubits/theme/theme_cubit.dart';
import '../cubits/theme/theme_state.dart';
import '../screens/geocam_screen.dart';
import '../screens/news_list_screen.dart';
import '../screens/bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;
  
  final List<Widget> _screens = const [
    GeoCamScreen(),
    NewsListScreen(),
    BookmarksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'GeoCam News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 500.ms),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey<bool>(state.isDarkMode),
                  ),
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
                tooltip: 'Toggle theme',
              ),
            ],
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: PageTransitionSwitcher(
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: _screens[_selectedIndex],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                _tabController.animateTo(index);
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'GeoCam',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
            ],
          ),
        );
      },
    );
  }
}