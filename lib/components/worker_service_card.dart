import 'package:flutter/material.dart';
import '../utils/customer_with_service.dart';

// Color Constants
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color listTileColor = Color(0xFFad8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);
const Color professionColor = Color(0xFFede0d4);
const Color nameColor = Color(0xFFe6ccb2);

class ServiceCard extends StatelessWidget {
  final ServiceWithCustomer serviceWithCustomer;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.serviceWithCustomer,
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
    return status
        .split('_')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
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
    final service = serviceWithCustomer.service;
    final details = serviceWithCustomer.serviceDetails;
    final status = serviceWithCustomer.status;

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
                    backgroundImage: serviceWithCustomer.customerAvatar != null
                        ? NetworkImage(serviceWithCustomer.customerAvatar!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: serviceWithCustomer.customerAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceWithCustomer.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: nameColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getTimeAgo(service.createdAt),
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
                      color: _getStatusColor(status).withValues(alpha: 0.2),
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
                  style: TextStyle(fontSize: 13, color: professionColor),
                ),
              const SizedBox(height: 10),
              if (service.location != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: secondaryTextColor,
                    ),
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
                  if (details?.startDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Started: ${details!.startDate!.day}/${details.startDate!.month}',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  // else if (details?.bookingDate != null)
                  //   Row(
                  //     children: [
                  //       Icon(Icons.event, size: 16, color: secondaryTextColor),
                  //       const SizedBox(width: 4),
                  //       Text(
                  //         'Booked: ${details!.bookingDate!.day}/${details.bookingDate!.month}',
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //           color: secondaryTextColor,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
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
