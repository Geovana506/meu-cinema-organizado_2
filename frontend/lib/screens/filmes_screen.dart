import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

// Espaço reservado para a listagem e o CRUD de filmes dos próximos encontros.
class FilmesScreen extends StatelessWidget {
  const FilmesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus filmes')),
      drawer: const AppDrawer(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.movie_creation_outlined, size: 64),
              SizedBox(height: 16),
              Text(
                'Sua coleção de filmes ficará aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'A listagem será implementada nos próximos encontros.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
