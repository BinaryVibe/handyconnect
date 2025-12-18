import 'package:flutter/material.dart';
import 'package:handyconnect/screens/customer_booking_screen.dart';
import 'package:handyconnect/utils/service_with_worker.dart';

const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color listTileColor = Color(0xFFad8042);
const Color nameColor = Color(0xffe6ccb2);
const Color professionColor = Color(0xFFede0d4);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);

class CustomerServiceCard extends StatelessWidget {
  final ServiceWithWorker serviceWithWorker;
  final VoidCallback onTap;

  const CustomerServiceCard({
    super.key,
    required this.serviceWithWorker,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = serviceWithWorker.service;
    final details = serviceWithWorker.serviceDetails;
    final status = serviceWithWorker.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: listTileColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: serviceWithWorker.workerAvatar != null
                        ? NetworkImage(serviceWithWorker.workerAvatar!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: serviceWithWorker.workerAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceWithWorker.workerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: nameColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          serviceWithWorker.workerProfession,
                          style: TextStyle(
                            fontSize: 12,
                            color: professionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(status),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.serviceTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: nameColor,
                ),
              ),
              const SizedBox(height: 6),
              if (service.description != null)
                Text(
                  service.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: professionColor,
                  ),
                ),
              const SizedBox(height: 10),
              if (service.location != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: secondaryTextColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        service.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(service.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (details?.price != null)
                    Row(
                      children: [
                        if (details!.paidStatus)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PAID',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          'Rs. ${details.price!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: nameColor,
                          ),
                        ),
                      ],
                    )
                  else if (status == 'pending')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagsBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Awaiting Response',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3E4C22),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

