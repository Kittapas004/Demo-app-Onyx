class ArtItem {
  final String title;
  final String imageUrl;
  final String startPrice;
  final String currentPrice;
  final String peopleCount;
  final String timeRemaining;

  ArtItem({
    required this.title,
    required this.imageUrl,
    this.startPrice = '\$0',
    this.currentPrice = '\$0',
    this.peopleCount = '0',
    this.timeRemaining = '00:00',
  });
}

class ArtRepository {
  ArtRepository._privateConstructor();
  static final ArtRepository instance = ArtRepository._privateConstructor();

  final List<ArtItem> _items = [
    ArtItem(
      title: 'Stupid Monkey',
      imageUrl: 'https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=800&q=80',
      startPrice: '\$5,000',
      currentPrice: '\$24,500',
      peopleCount: '22',
      timeRemaining: '01:23',
    ),
    ArtItem(
      title: 'Fake Girl',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&q=80',
      startPrice: '\$3,400',
      currentPrice: '\$5,600',
      peopleCount: '9',
      timeRemaining: '09:23',
    ),
  ];

  List<ArtItem> get items => List.unmodifiable(_items);

  void add(ArtItem item) {
    _items.insert(0, item);
  }
}
