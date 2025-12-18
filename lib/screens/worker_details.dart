import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/worker.dart';
import '../providers/service_provider.dart'; // Required for fetching stats

// --- Color Constants ---
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color listTileColor = Color(0xFFad8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);
const Color professionColor = Color(0xFFede0d4);
const Color nameColor = Color(0xFFe6ccb2);

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  final WorkerServiceHandler _workerHandler = WorkerServiceHandler();
  
  // Dynamic State Variables
  bool _isLoadingStats = true;
  int _completedJobs = 0;
  double _totalEarnings = 0.0;
  double _dynamicRating = 0.0;

  @override
  void initState() {
    super.initState();
    // 1. Initialize with the data passed from Dashboard (so it's not empty)
    _dynamicRating = widget.worker.avgRating; 
    _totalEarnings = widget.worker.earnings;

    // 2. Fetch the REAL, fresh data from Supabase immediately
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Calls the function in service_provider.dart
    final stats = await _workerHandler.fetchWorkerStats(widget.worker.id);
    
    if (mounted) {
      setState(() {
        _completedJobs = stats['completedJobs'];
        _totalEarnings = stats['totalEarnings'];
        _dynamicRating = stats['avgRating']; 
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isMobile),
              SliverToBoxAdapter(
                child: isMobile
                    ? _buildMobileLayout(context)
                    : _buildDesktopLayout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isMobile) {
    final worker = widget.worker;
    return SliverAppBar(
      expandedHeight: isMobile ? 300 : 320,
      floating: false,
      pinned: true,
      backgroundColor: kPrimaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kPrimaryColor, listTileColor],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Hero(
                  tag: 'worker-avatar-${worker.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isMobile ? 60 : 70,
                      backgroundImage: worker.avatarUrl != null
                          ? NetworkImage(worker.avatarUrl!)
                          : null,
                      backgroundColor: Colors.white,
                      child: worker.avatarUrl == null
                          ? Icon(Icons.person, size: isMobile ? 60 : 70, color: kPrimaryColor)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${worker.firstName} ${worker.lastName}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (worker.verifiedStatus) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 24),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: professionColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    worker.profession,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvailabilityCard(),
          const SizedBox(height: 16),
          _buildStatsCard(), // DYNAMIC STATS CARD
          const SizedBox(height: 16),
          _buildContactCard(),
          const SizedBox(height: 16),
          _buildSkillsSection(),
          const SizedBox(height: 16),
          _buildAboutSection(),
          const SizedBox(height: 24),
          _buildHireButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildAvailabilityCard(),
                    const SizedBox(height: 16),
                    _buildStatsCard(), // DYNAMIC STATS CARD
                    const SizedBox(height: 16),
                    _buildContactCard(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildSkillsSection(),
                    const SizedBox(height: 16),
                    _buildAboutSection(),
                    const SizedBox(height: 24),
                    _buildHireButton(context),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.worker.availability ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.worker.availability ? 'Available Now' : 'Currently Busy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.worker.availability ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC STATS CARD (Uses fetched data) ---
  Widget _buildStatsCard() {
    if (_isLoadingStats) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: listTileColor,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: listTileColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: nameColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.star, _dynamicRating.toStringAsFixed(1), 'Rating', Colors.amber),
                Container(height: 50, width: 1, color: professionColor),
                _buildStatItem(Icons.work, _completedJobs.toString(), 'Jobs Done', Colors.white),
                Container(height: 50, width: 1, color: professionColor),
                // Displaying earnings. Using toInt() for cleanliness. 
                // You can change to 'Rs. ${(_totalEarnings/1000).toStringAsFixed(0)}k' if you prefer "1k" format.
                _buildStatItem(Icons.attach_money, 'Rs. ${_totalEarnings.toInt()}', 'Earnings', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: nameColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: professionColor)),
      ],
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'Email', widget.worker.email),
            const SizedBox(height: 12),
            _buildContactItem(Icons.phone, 'Phone', widget.worker.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kFieldColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: secondaryTextColor)),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kPrimaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.build, color: kPrimaryColor),
                SizedBox(width: 8),
                Text('Skills & Expertise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.worker.skills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: tagsBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3E4C22), width: 1),
                ),
                child: Text(skill, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3E4C22))),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final worker = widget.worker;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: kPrimaryColor),
                SizedBox(width: 8),
                Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Professional ${worker.profession.toLowerCase()} with expertise in ${worker.skills.take(3).join(", ")}. '
              '${worker.verifiedStatus ? "Verified and background-checked for your safety. " : ""}'
              'With an average rating of ${_dynamicRating.toStringAsFixed(1)} stars, '
              '${worker.firstName} has successfully completed numerous projects.',
              style: TextStyle(fontSize: 14, height: 1.6, color: kPrimaryColor.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHireButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.worker.availability
            ? () => _showHireDialog(context)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: widget.worker.availability ? 5 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.worker.availability ? Icons.check_circle : Icons.schedule, size: 24),
            const SizedBox(width: 12),
            Text(
              widget.worker.availability ? 'Hire ${widget.worker.firstName}' : 'Currently Unavailable',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showHireDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.work, color: kPrimaryColor),
            SizedBox(width: 8),
            Text('Hire Worker', style: TextStyle(color: kPrimaryColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to send a service request to:', style: TextStyle(color: kPrimaryColor.withOpacity(0.8))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: listTileColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: widget.worker.avatarUrl != null ? NetworkImage(widget.worker.avatarUrl!) : null,
                    backgroundColor: kFieldColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.worker.firstName} ${widget.worker.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                        Text(widget.worker.profession, style: const TextStyle(color: secondaryTextColor, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('You will be redirected to the booking form.', style: TextStyle(fontSize: 13, color: kPrimaryColor.withOpacity(0.7))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel', style: TextStyle(color: secondaryTextColor))),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.push('/c-dashboard/w-details/book-service', extra: widget.worker);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}