import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/placeholder_image.dart';

class AuctionDetailPageNew extends StatefulWidget {
  final String artworkId;
  final String title;
  final String artist;
  final String artistId;
  final String imageUrl;
  final double startingPrice;
  final double currentPrice;
  final int bidCount;

  const AuctionDetailPageNew({
    super.key,
    required this.artworkId,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.imageUrl,
    required this.startingPrice,
    required this.currentPrice,
    required this.bidCount,
  });

  @override
  State<AuctionDetailPageNew> createState() => _AuctionDetailPageNewState();
}

class _AuctionDetailPageNewState extends State<AuctionDetailPageNew> {
  final TextEditingController _customBidController = TextEditingController();
  late double _selectedBid;
  bool _isPlacingBid = false;

  // Countdown timer
  late Duration _totalDuration;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedBid = widget.currentPrice + 2000;
    _totalDuration = const Duration(minutes: 1, seconds: 23);
    _remaining = _totalDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          if (_remaining.inSeconds > 0) {
            _remaining = Duration(seconds: _remaining.inSeconds - 1);
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _customBidController.dispose();
    super.dispose();
  }

  Future<void> _placeBid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place bid')),
      );
      return;
    }

    // Check if user is bidding on their own artwork
    if (user.uid == widget.artistId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot bid on your own artwork')),
      );
      return;
    }

    // Validate bid amount
    if (_selectedBid <= widget.currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid must be higher than current price')),
      );
      return;
    }

    setState(() => _isPlacingBid = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = await authService.getUserData(user.uid);
      final userName = userData?['name'] ?? 'Anonymous';

      final firestoreService = FirestoreService();
      await firestoreService.placeBid({
        'auctionId': widget.artworkId,
        'artworkId': widget.artworkId,
        'bidderId': user.uid,
        'bidderName': userName,
        'bidAmount': _selectedBid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Update selected bid for next bid
        setState(() {
          _selectedBid = _selectedBid + 2000;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place bid: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingBid = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 28),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildArtworkImage(),
                    _buildAuctionInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ArtworkImage(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              height: 400,
              placeholderIconSize: 100,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAuctionInfoCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue[300],
                      child: Text(
                        widget.artist.isNotEmpty ? widget.artist[0].toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.artist,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildPriceInfo(),
                const SizedBox(height: 24),
                _buildLiveAuctionSection(),
                const SizedBox(height: 24),
                _buildBiddersSection(),
                const SizedBox(height: 24),
                _buildBidOptions(),
                const SizedBox(height: 12),
                _buildCustomBidButton(),
                const SizedBox(height: 16),
                _buildPlaceBidButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).snapshots(),
      builder: (context, snapshot) {
        double currentPrice = widget.currentPrice;
        int bidCount = widget.bidCount;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          currentPrice = (data['currentBid'] ?? currentPrice).toDouble();
          bidCount = data['bidCount'] ?? bidCount;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Start Price',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_formatPrice(widget.startingPrice)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(width: 1, height: 50, color: Colors.grey[300]),
              Column(
                children: [
                  Text(
                    'Current Bid',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_formatPrice(currentPrice)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 50, color: Colors.grey[300]),
              Column(
                children: [
                  Text(
                    'Bidders',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$bidCount',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveAuctionSection() {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Live Auction',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              timeString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiddersSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bids')
          .where('artworkId', isEqualTo: widget.artworkId)
          .orderBy('bidAmount', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No bids yet. Be the first!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final bids = snapshot.data!.docs;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Bidders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...bids.asMap().entries.map((entry) {
                final index = entry.key;
                final bid = entry.value.data() as Map<String, dynamic>;
                final bidderName = bid['bidderName'] ?? 'Anonymous';
                final bidAmount = (bid['bidAmount'] ?? 0).toDouble();
                final isHighest = index == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHighest ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHighest ? Colors.green : Colors.grey[200]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isHighest ? Colors.green : Colors.blue[300],
                        child: Text(
                          bidderName.isNotEmpty ? bidderName[0].toUpperCase() : 'A',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  bidderName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isHighest ? Colors.green[700] : Colors.black87,
                                  ),
                                ),
                                if (isHighest) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Highest',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${_formatPrice(bidAmount)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isHighest)
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBidOptions() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('artworks').doc(widget.artworkId).snapshots(),
      builder: (context, snapshot) {
        double currentPrice = widget.currentPrice;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          currentPrice = (data['currentBid'] ?? currentPrice).toDouble();
        }

        final quickBids = [
          currentPrice + 2000,
          currentPrice + 4000,
          currentPrice + 6000,
          currentPrice + 8000,
        ];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickBids.map((bid) {
            final isSelected = _selectedBid == bid;
            return ChoiceChip(
              label: Text('\$${_formatPrice(bid)}'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedBid = bid);
                }
              },
              selectedColor: const Color(0xFF1E293B),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCustomBidButton() {
    return TextField(
      controller: _customBidController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Custom Bid Amount (\$)',
        hintText: 'Enter amount',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.check_circle),
          onPressed: () {
            final amount = double.tryParse(_customBidController.text);
            if (amount != null && amount > widget.currentPrice) {
              setState(() => _selectedBid = amount);
              _customBidController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter valid amount higher than current price')),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPlaceBidButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isPlacingBid ? null : _placeBid,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isPlacingBid
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Place Bid for \$${_formatPrice(_selectedBid)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    }
    return price.toStringAsFixed(0);
  }
}
