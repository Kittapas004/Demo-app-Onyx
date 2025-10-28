import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/confirm_bid_dialog.dart';
import '../widgets/placeholder_image.dart';

class AuctionDetailPage extends StatefulWidget {
  final String title;
  final String artist;
  final String imageUrl;

  const AuctionDetailPage({
    super.key,
    required this.title,
    required this.artist,
    required this.imageUrl,
  });

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  int selectedBidIndex = 3;
  final List<String> bidOptions = ['\$26k', '\$28k', '\$32k', '\$35k'];
  // Countdown timer
  late Duration _totalDuration;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _totalDuration = const Duration(minutes: 1, seconds: 23); // default example
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
    super.dispose();
  }

  void _resetTimer() {
    setState(() {
      _remaining = _totalDuration;
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0 ? Colors.black : Colors.grey[400],
                ),
              ),
            ),
          ),
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
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
                      ),
                      backgroundColor: Color(0xFF1E293B),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Starting price', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    const Text('\$5,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Bid Price', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    const Text('\$24,500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // Countdown progress + label
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 12,
                    child: LinearProgressIndicator(
                      value: _totalDuration.inSeconds > 0 ? _remaining.inSeconds / _totalDuration.inSeconds : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  // Green label on top of the bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remaining.inSeconds.remainder(60).toString().padLeft(2, '0')} remaining',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 24,
                          child: Stack(
                            children: List.generate(5, (index) {
                              return Positioned(
                                left: index * 16.0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == 4 ? Colors.white : null,
                                    border: Border.all(color: Colors.white, width: 2),
                                    image: index < 4
                                        ? DecorationImage(
                                            image: NetworkImage('https://i.pravatar.cc/150?img=${index + 1}'),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: index == 4
                                      ? const Center(child: Text('+24', style: TextStyle(fontSize: 8)))
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('are live'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 4),
                      Text('${_remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remaining.inSeconds.remainder(60).toString().padLeft(2, '0')} remaining', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAuctionSection() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
            ),
            const SizedBox(width: 8),
            const Text('Live Auction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Text('14 Bids made', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        _buildBidderItem('Ronald Richards', '20s', '\$24.5k', Colors.blue[300]!),
        const SizedBox(height: 12),
        _buildBidderItem('Cameron Williamson', '1m', '\$20k', Colors.pink[300]!),
      ],
    );
  }

  Widget _buildBidderItem(String name, String time, String amount, Color avatarColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(time, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBidOptions() {
    return Row(
      children: List.generate(
        bidOptions.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < bidOptions.length - 1 ? 8 : 0),
            child: OutlinedButton(
              onPressed: () => setState(() => selectedBidIndex = index),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(bidOptions[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBidButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _showCustomBidDialog();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF1E293B)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('use custom bid'),
      ),
    );
  }

  void _showCustomBidDialog() {
    final TextEditingController customBidController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Bid'),
        content: TextField(
          controller: customBidController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter amount',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (customBidController.text.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => const ConfirmBidDialog(),
                ).then((_) {
                  _resetTimer();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceBidButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => const ConfirmBidDialog()
          ).then((_) {
            // รีเซ็ตเวลาหลังจากกด Place Bid
            _resetTimer();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: const Text(
          'Place Bid for \$25k',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
