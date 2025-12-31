import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/live_stream.dart';
import '../models/category.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../widgets/cached_image.dart';
import 'video_player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
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

    final categories = auth.liveCategories;
    final allChannels = auth.liveStreams;

    // Filter channels by category and search
    final List<LiveStream> filteredChannels = allChannels.where((channel) {
      final matchesCategory = _selectedCategoryId == null ||
          channel.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty ||
          channel.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (isDesktop) {
      return _buildDesktopLayout(categories, filteredChannels, l10n);
    } else {
      return _buildMobileLayout(categories, filteredChannels, l10n);
    }
  }

  Widget _buildDesktopLayout(
    List<Category> categories,
    List<LiveStream> channels,
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
                  Icons.grid_view,
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

        // Channels grid
        Expanded(child: _buildChannelsGrid(channels, l10n)),
      ],
    );
  }

  Widget _buildMobileLayout(
    List<Category> categories,
    List<LiveStream> channels,
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

        // Channels grid
        Expanded(child: _buildChannelsGrid(channels, l10n)),
      ],
    );
  }

  Widget _buildChannelsGrid(List<LiveStream> channels, AppLocalizations? l10n) {
    if (channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              l10n?.noChannelsFound ?? 'No channels found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;
    final crossAxisCount = isDesktop ? 5 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        return _buildChannelCard(channel);
      },
    );
  }

  Widget _buildChannelCard(LiveStream channel) {
    final auth = context.read<AuthController>();

    return Material(
      color: const Color(0xFF2D2D2D),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final streamUrl = AppConfig.buildLiveStreamUrl(
            auth.userInfo!.username,
            auth.userInfo!.password,
            channel.streamId.toString(),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                streamUrl: streamUrl,
                title: channel.name,
                logoUrl: channel.streamIcon,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CachedImage(
                  imageUrl: channel.streamIcon,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                channel.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.tv, color: Colors.grey, size: 32)),
    );
  }
}
