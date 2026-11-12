import 'package:flutter/material.dart';

import '../../models/tour_service.dart';
import '../../services/tour_service.dart';
import '../tour/tour_detail_view.dart';

class HomeView extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeView({
    super.key,
    required this.userData,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const Color primaryColor = Color(0xFF075E59);
  static const Color backgroundColor = Color(0xFFF7F4ED);
  static const Color textColor = Color(0xFF263238);
  static const Color secondaryColor = Color(0xFF64748B);

  final TourServiceApi _tourService = TourServiceApi();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String?>> categories = [
    {'label': 'Todas', 'value': null},
    {'label': 'Históricas', 'value': 'HISTORICAL'},
    {'label': 'Islas y playas', 'value': 'ISLANDS_AND_BEACHES'},
    {'label': 'Gastronomía', 'value': 'GASTRONOMIC'},
    {'label': 'Culturales', 'value': 'CULTURAL'},
    {'label': 'Vida nocturna', 'value': 'NIGHTLIFE'},
  ];

  List<TourService> tours = [];

  String? selectedCategory;

  int currentPage = -1;
  int totalElements = 0;

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTours(refresh: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 350) {
      _loadTours();
    }
  }

  Future<void> _loadTours({bool refresh = false}) async {
    if (!refresh && (isLoading || isLoadingMore || !hasMore)) {
      return;
    }

    if (refresh) {
      setState(() {
        isLoading = true;
        isLoadingMore = false;
        errorMessage = null;
        currentPage = -1;
        tours = [];
        hasMore = true;
      });
    } else {
      setState(() {
        isLoadingMore = true;
        errorMessage = null;
      });
    }

    final requestedPage = refresh ? 0 : currentPage + 1;

    try {
      final result = await _tourService.getTours(
        page: requestedPage,
        size: 10,
        category: selectedCategory,
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          tours = result.content;
        } else {
          tours.addAll(result.content);
        }

        currentPage = result.page;
        totalElements = result.totalElements;
        hasMore = tours.length < totalElements;

        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _selectCategory(String? category) {
    if (selectedCategory == category) return;

    setState(() {
      selectedCategory = category;
    });

    _loadTours(refresh: true);
  }

  void _openTourDetail(TourService tour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailView(
          tourId: tour.id,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'HISTORICAL':
        return 'HISTÓRICA';
      case 'ISLANDS_AND_BEACHES':
        return 'ISLAS Y PLAYAS';
      case 'GASTRONOMIC':
        return 'GASTRONÓMICA';
      case 'CULTURAL':
        return 'CULTURAL';
      case 'NIGHTLIFE':
        return 'VIDA NOCTURNA';
      default:
        return category.replaceAll('_', ' ');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tourService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userData['name'] ?? 'Usuario';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Localy',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => _loadTours(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(name.toString()),
            ),
            SliverToBoxAdapter(
              child: _buildCategories(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Experiencias para ti',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (!isLoading)
                      Text(
                        '$totalElements disponibles',
                        style: const TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              )
            else if (errorMessage != null && tours.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(),
              )
            else if (tours.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No encontramos experiencias en esta categoría.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildTourCard(tours[index]);
                    },
                    childCount: tours.length,
                  ),
                ),
              ),
            if (isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            if (errorMessage != null && tours.isNotEmpty)
              SliverToBoxAdapter(
                child: TextButton(
                  onPressed: () => _loadTours(),
                  child: const Text(
                    'No se pudieron cargar más. Reintentar',
                  ),
                ),
              ),
            if (!hasMore && tours.isNotEmpty && !isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 28, top: 8),
                  child: Center(
                    child: Text(
                      'Has llegado al final de las experiencias',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $name!',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Conecta con lo auténtico.',
            style: TextStyle(
              fontSize: 15,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE8E5DE),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: primaryColor,
                  size: 23,
                ),
                SizedBox(width: 10),
                Text(
                  'Descubre tu próxima experiencia',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final category = categories[index];
          final value = category['value'];
          final isSelected = selectedCategory == value;

          return ChoiceChip(
            label: Text(category['label']!),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => _selectCategory(value),
            backgroundColor: Colors.white,
            selectedColor: primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            side: BorderSide(
              color: isSelected
                  ? primaryColor
                  : const Color(0xFFE5E1D8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourCard(TourService tour) {
    return InkWell(
      onTap: () => _openTourDetail(tour),
      borderRadius: BorderRadius.circular(17),
      child: Card(
        margin: const EdgeInsets.only(bottom: 17),
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (tour.photos.isNotEmpty)
                  Image.network(
                    tour.photos.first,
                    height: 185,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                else
                  _imagePlaceholder(),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatCategory(tour.category),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 19,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 17,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          tour.guideName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF4B400),
                        size: 19,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        tour.reviewCount > 0
                            ? tour.averageRating.toStringAsFixed(1)
                            : 'Nuevo',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (tour.reviewCount > 0)
                        Text(
                          ' (${tour.reviewCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: secondaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const Divider(
                    height: 1,
                    color: Color(0xFFECECEC),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Desde',
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryColor,
                        ),
                      ),
                      Text(
                        _formatPrice(tour.price),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 185,
      width: double.infinity,
      color: const Color(0xFFE9E8E2),
      child: const Icon(
        Icons.image_outlined,
        size: 42,
        color: secondaryColor,
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 50,
            color: secondaryColor,
          ),
          const SizedBox(height: 15),
          Text(
            errorMessage ?? 'No se pudieron cargar las experiencias.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textColor),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _loadTours(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Intentar nuevamente'),
          ),
        ],
      ),
    );
  }
}