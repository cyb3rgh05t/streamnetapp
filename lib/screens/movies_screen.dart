import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/vod_stream.dart';
import '../models/category.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../widgets/cached_image.dart';
import 'video_player_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final l10n = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final categories = auth.vodCategories;
    final allMovies = auth.vodStreams;

    // Filter movies by category and search
    final List<VodStream> filteredMovies = allMovies.where((movie) {
      final matchesCategory = _selectedCategoryId == null ||
          movie.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          movie.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (isDesktop) {
      return _buildDesktopLayout(categories, filteredMovies, l10n);
    } else {
      return _buildMobileLayout(categories, filteredMovies, l10n);
    }
  }

  Widget _buildDesktopLayout(
    List<Category> categories,
    List<VodStream> movies,
    AppLocalizations? l10n,
  ) {
    return Row(
      children: [
        // Categories sidebar
        Container(
          width: 250,
          color: const Color(0xFF1E1E1E),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: l10n?.search ?? 'Search',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF2D2D2D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),

              // "All" category
              ListTile(
                leading: const Icon(Icons.movie, color: AppConfig.primaryColor),
                title: Text(l10n?.allCategories ?? 'All Categories'),
                selected: _selectedCategoryId == null,
                selectedTileColor: AppConfig.primaryColor.withOpacity(0.1),
                onTap: () => setState(() => _selectedCategoryId = null),
              ),

              const Divider(height: 1),

              // Categories list
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(
                        category.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: _selectedCategoryId == category.categoryId,
                      selectedTileColor: AppConfig.primaryColor.withOpacity(
                        0.1,
                      ),
                      onTap: () => setState(
                        () => _selectedCategoryId = category.categoryId,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Movies grid
        Expanded(child: _buildMoviesGrid(movies, l10n)),
      ],
    );
  }

  Widget _buildMobileLayout(
    List<Category> categories,
    List<VodStream> movies,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: l10n?.search ?? 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Categories horizontal list
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    key: const ValueKey('all_category'),
                    label: Text(l10n?.allCategories ?? 'All'),
                    selected: _selectedCategoryId == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = null),
                    selectedColor: AppConfig.primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedCategoryId == null
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                );
              }

              final category = categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  key: ValueKey('category_${category.categoryId}'),
                  label: Text(category.categoryName),
                  selected: _selectedCategoryId == category.categoryId,
                  onSelected: (_) =>
                      setState(() => _selectedCategoryId = category.categoryId),
                  selectedColor: AppConfig.primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedCategoryId == category.categoryId
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              );
            },
          ),
        ),

        // Movies grid
        Expanded(child: _buildMoviesGrid(movies, l10n)),
      ],
    );
  }

  Widget _buildMoviesGrid(List<VodStream> movies, AppLocalizations? l10n) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              l10n?.noMoviesFound ?? 'No movies found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;
    final crossAxisCount = isDesktop ? 6 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(movie);
      },
    );
  }

  Widget _buildMovieCard(VodStream movie) {
    final auth = context.read<AuthController>();

    return Material(
      color: const Color(0xFF2D2D2D),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showMovieDetails(movie, auth);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Movie poster
            Expanded(
              child: CachedPosterImage(
                imageUrl: movie.streamIcon,
                fit: BoxFit.cover,
              ),
            ),

            // Movie title
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.rating != null && movie.rating! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppConfig.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      color: const Color(0xFF3D3D3D),
      child: const Center(
        child: Icon(Icons.movie, color: Colors.grey, size: 48),
      ),
    );
  }

  void _showMovieDetails(VodStream movie, AuthController auth) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Movie poster
                  if (movie.streamIcon != null && movie.streamIcon!.isNotEmpty)
                    Container(
                      height: 300,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedPosterImage(
                        imageUrl: movie.streamIcon,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Movie info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (movie.rating != null && movie.rating! > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppConfig.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Play button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);

                              final streamUrl = AppConfig.buildVodStreamUrl(
                                auth.userInfo!.username,
                                auth.userInfo!.password,
                                movie.streamId.toString(),
                                movie.containerExtension ?? 'mp4',
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerScreen(
                                    streamUrl: streamUrl,
                                    title: movie.name,
                                    logoUrl: movie.streamIcon,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n?.playNow ?? 'Play Now',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
