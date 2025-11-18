import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../widgets/placeholder_image.dart';
import 'auction_detail_page_new.dart';

class MyAuctionPage extends StatefulWidget {
  const MyAuctionPage({super.key});

  @override
  State<MyAuctionPage> createState() => _MyAuctionPageState();
}

class _MyAuctionPageState extends State<MyAuctionPage> {
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        final userData = await authService.getUserData(currentUser.uid);
        
        if (mounted && userData != null) {
          setState(() {
            _userName = userData['name'] ?? currentUser.email?.split('@').first ?? 'User';
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Auction',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please login to view your auctions'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _userName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Show participated auctions (latest bids)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bids')
                        .where('bidderId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, bidSnapshot) {
                      if (bidSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (bidSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              'Error: ${bidSnapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        );
                      }

                      if (!bidSnapshot.hasData || bidSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text(
                              'No active auctions.\nBid on artworks to see them here!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        );
                      }

                      // Get unique artwork IDs (keeping latest bid per artwork)
                      final artworkMap = <String, QueryDocumentSnapshot>{};
                      for (var doc in bidSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final artworkId = data['artworkId'];
                        if (artworkId != null && !artworkMap.containsKey(artworkId)) {
                          artworkMap[artworkId] = doc;
                        }
                      }

                      if (artworkMap.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text(
                              'No active auctions.\nBid on artworks to see them here!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: artworkMap.entries.map((entry) {
                          final artworkId = entry.key;

                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('artworks')
                                .doc(artworkId)
                                .snapshots(),
                            builder: (context, artworkSnapshot) {
                              if (!artworkSnapshot.hasData) {
                                return const SizedBox();
                              }

                              final artworkData = artworkSnapshot.data!.data() as Map<String, dynamic>?;
                              if (artworkData == null) {
                                return const SizedBox();
                              }

                              final isWinning = artworkData['highestBidderId'] == currentUser.uid;
                              final currentBid = artworkData['currentBid'] ?? artworkData['startPrice'] ?? 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isWinning ? Colors.green.shade200 : Colors.grey.shade300,
                                    width: isWinning ? 2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AuctionDetailPageNew(
                                          artworkId: artworkId,
                                          title: artworkData['title'] ?? 'Untitled',
                                          artist: artworkData['artistName'] ?? 'Unknown',
                                          artistId: artworkData['artistId'] ?? '',
                                          imageUrl: artworkData['imageUrl'] ?? '',
                                          startingPrice: (artworkData['startPrice'] ?? 0).toDouble(),
                                          currentPrice: (artworkData['currentBid'] ?? artworkData['startPrice'] ?? 0).toDouble(),
                                          bidCount: artworkData['bidCount'] ?? 0,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Artwork image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: ArtworkImage(
                                            imageUrl: artworkData['imageUrl'] ?? '',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Artwork details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                artworkData['title'] ?? 'Untitled',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Artist: ${artworkData['artistName'] ?? 'Unknown'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Current Bid',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                      Text(
                                                        '\$${(currentBid / 1000).toStringAsFixed(1)}k',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: isWinning ? Colors.green : Colors.orange,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              if (isWinning) ...[
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.emoji_events,
                                                        size: 16,
                                                        color: Colors.green.shade700,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Highest Bidder',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.green.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
