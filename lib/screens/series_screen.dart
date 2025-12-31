import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/series_stream.dart';
import '../models/category.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import 'video_player_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
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

    final categories = auth.seriesCategories;
    final allSeries = auth.seriesStreams;

    // Filter series by category and search
    final List<SeriesStream> filteredSeries = allSeries.where((series) {
      final matchesCategory = _selectedCategoryId == null ||
          series.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          series.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (isDesktop) {
      return _buildDesktopLayout(categories, filteredSeries, l10n);
    } else {
      return _buildMobileLayout(categories, filteredSeries, l10n);
    }
  }

  Widget _buildDesktopLayout(
    List<Category> categories,
    List<SeriesStream> series,
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
                leading: const Icon(
                  Icons.video_library,
                  color: AppConfig.primaryColor,
                ),
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

        // Series grid
        Expanded(child: _buildSeriesGrid(series, l10n)),
      ],
    );
  }

  Widget _buildMobileLayout(
    List<Category> categories,
    List<SeriesStream> series,
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

        // Series grid
        Expanded(child: _buildSeriesGrid(series, l10n)),
      ],
    );
  }

  Widget _buildSeriesGrid(List<SeriesStream> series, AppLocalizations? l10n) {
    if (series.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              l10n?.noSeriesFound ?? 'No series found',
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
      itemCount: series.length,
      itemBuilder: (context, index) {
        final item = series[index];
        return _buildSeriesCard(item);
      },
    );
  }

  Widget _buildSeriesCard(SeriesStream series) {
    return Material(
      color: const Color(0xFF2D2D2D),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showSeriesDetails(series),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Series cover
            Expanded(
              child: series.cover != null && series.cover!.isNotEmpty
                  ? Image.network(
                      series.cover!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                    )
                  : _buildPlaceholderCover(),
            ),

            // Series title
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (series.rating != null && series.rating! > 0)
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
                            series.rating!.toStringAsFixed(1),
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

  Widget _buildPlaceholderCover() {
    return Container(
      color: const Color(0xFF3D3D3D),
      child: const Center(child: Icon(Icons.tv, color: Colors.grey, size: 48)),
    );
  }

  void _showSeriesDetails(SeriesStream series) async {
    final auth = context.read<AuthController>();
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SeriesDetailSheet(series: series, auth: auth, l10n: l10n);
      },
    );
  }
}

class SeriesDetailSheet extends StatefulWidget {
  final SeriesStream series;
  final AuthController auth;
  final AppLocalizations? l10n;

  const SeriesDetailSheet({
    super.key,
    required this.series,
    required this.auth,
    this.l10n,
  });

  @override
  State<SeriesDetailSheet> createState() => _SeriesDetailSheetState();
}

class _SeriesDetailSheetState extends State<SeriesDetailSheet> {
  Map<String, dynamic>? _seriesInfo;
  bool _isLoading = true;
  int _selectedSeason = 0;

  @override
  void initState() {
    super.initState();
    _loadSeriesInfo();
  }

  Future<void> _loadSeriesInfo() async {
    try {
      final info = await ApiService.getSeriesInfo(
        username: widget.auth.userInfo!.username,
        password: widget.auth.userInfo!.password,
        seriesId: widget.series.seriesId,
      );
      if (mounted) {
        setState(() {
          _seriesInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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

              // Series cover
              if (widget.series.cover != null &&
                  widget.series.cover!.isNotEmpty)
                Container(
                  height: 250,
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
                  child: Image.network(widget.series.cover!, fit: BoxFit.cover),
                ),

              // Series info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.series.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.series.rating != null &&
                        widget.series.rating! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppConfig.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.series.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    if (widget.series.plot != null &&
                        widget.series.plot!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          widget.series.plot!,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Loading or Episodes
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppConfig.primaryColor,
                    ),
                  ),
                )
              else if (_seriesInfo != null)
                _buildSeasonsAndEpisodes(),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeasonsAndEpisodes() {
    final episodes = _seriesInfo!['episodes'] as Map<String, dynamic>?;
    if (episodes == null || episodes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.l10n?.noEpisodesFound ?? 'No episodes found',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final seasons = episodes.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: seasons.length,
              itemBuilder: (context, index) {
                final season = seasons[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: ValueKey('season_$season'),
                    label: Text('${widget.l10n?.season ?? 'Season'} $season'),
                    selected: _selectedSeason == index,
                    onSelected: (_) => setState(() => _selectedSeason = index),
                    selectedColor: AppConfig.primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedSeason == index
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Episodes list
        if (seasons.isNotEmpty)
          _buildEpisodesList(
            episodes[seasons[_selectedSeason]] as List<dynamic>,
          ),
      ],
    );
  }

  Widget _buildEpisodesList(List<dynamic> episodeList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodeList.length,
      itemBuilder: (context, index) {
        final episode = episodeList[index] as Map<String, dynamic>;
        final title = episode['title'] ??
            'Episode ${episode['episode_num'] ?? index + 1}';
        final episodeNum = episode['episode_num']?.toString() ?? '${index + 1}';

        return ListTile(
          leading: Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'E$episodeNum',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: episode['info']?['duration'] != null
              ? Text('${episode['info']['duration']}')
              : null,
          trailing: IconButton(
            icon: const Icon(
              Icons.play_circle,
              color: AppConfig.primaryColor,
              size: 32,
            ),
            onPressed: () {
              Navigator.pop(context);

              final streamUrl = AppConfig.buildSeriesStreamUrl(
                widget.auth.userInfo!.username,
                widget.auth.userInfo!.password,
                episode['id'].toString(),
                episode['container_extension'] ?? 'mp4',
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    streamUrl: streamUrl,
                    title: widget.series.name,
                    subtitle: title,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
