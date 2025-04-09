import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a mi app de Pokémon'),
      ),
      body: Stack(
        children: [
          // Fondo con imagen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://cdn.pixabay.com/photo/2020/05/04/11/04/pokeball-5128709_1280.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido principal
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const TitleSection(
                  name: 'Bienvenido al catálogo de Pokémon',
                  location: 'Anime',
                ),
                const TitleSection(
                  name: 'Explora y descubre',
                  location:
                      'En esta app podrás ver nombres e imágenes de Pokémon.',
                ),
                const ButtonSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key, required this.name, required this.location});

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6), // Fondo semitransparente
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PokemonGridView(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Explorar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white, 
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonGridView extends StatefulWidget {
  const PokemonGridView({super.key});

  @override
  _PokemonGridViewState createState() => _PokemonGridViewState();
}

class _PokemonGridViewState extends State<PokemonGridView> {
  late Future<List<Map<String, dynamic>>> _pokemonList;

  Future<List<Map<String, dynamic>>> fetchPokemon() async {
    try {
      const url = 'https://pokeapi.co/api/v2/pokemon?limit=50';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((pokemon) => {
                  'name': pokemon['name'],
                  'imageUrl':
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['url'].split('/')[6]}.png'
                })
            .toList();
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      throw Exception('No se pudo conectar con la API: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _pokemonList = fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Pokémon'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error al cargar los datos'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _pokemonList = fetchPokemon();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final pokemonList = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                return Card(
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        pokemon['imageUrl'],
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pokemon['name'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }
}
