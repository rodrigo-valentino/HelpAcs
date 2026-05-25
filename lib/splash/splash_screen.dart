// lib/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_initializer.dart';
import '../home/pages/home_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  
  bool _hasNavigated = false;

  // Cor exata do seu pubspec.yaml para dar continuidade ao splash nativo
  static const _bgColor = Color(0xFFA9CCE3);

  @override
  void initState() {
    super.initState();
    
    // Animação suave para os elementos que vão aparecer sobre o fundo
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appInitializerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(appInitializerProvider);

    if (initState.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToHome());
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const Spacer(),
              
              // ── Área central: Logo do Projeto ───────────────────────────
              Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo_foreground.png',
                    width: 160, // Ajustado ligeiramente para casar com o tamanho do Android
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text(
                'HelpACS',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                'Agente Comunitário de Saúde',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ── Área inferior: Progresso ────────────────────────────────
              _BottomSection(initState: initState),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEÇÃO INFERIOR — Barra de progresso + mensagem dinâmica
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final InitializationState initState;

  const _BottomSection({required this.initState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: initState.progress),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.white60,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildMessage(initState),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(InitializationState state) {
    if (state.hasError) {
      return Text(
        state.errorMessage ?? 'Erro desconhecido',
        key: const ValueKey('error'),
        style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      state.message,
      key: ValueKey(state.message),
      style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}