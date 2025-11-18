import 'package:flutter/material.dart';
import '../utils/network_helper.dart';
import '../utils/app_config.dart';

/// Widget that displays network connection status and debugging information
class NetworkStatusIndicator extends StatefulWidget {
  final Widget child;
  final bool showInProduction;

  const NetworkStatusIndicator({
    super.key,
    required this.child,
    this.showInProduction = false,
  });

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  NetworkStatus? _networkStatus;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    if (AppConfig.isDebugMode || widget.showInProduction) {
      _checkNetworkStatus();
    }
  }

  Future<void> _checkNetworkStatus() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final status = await NetworkHelper.checkNetworkHealth();
      if (mounted) {
        setState(() => _networkStatus = status);
      }
    } catch (e) {
      debugPrint('Network status check failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if ((AppConfig.isDebugMode || widget.showInProduction) &&
            (_networkStatus != null || _isChecking))
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            right: 16,
            child: _buildNetworkIndicator(),
          ),
      ],
    );
  }

  Widget _buildNetworkIndicator() {
    if (_isChecking) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Checking...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_networkStatus == null) return const SizedBox();

    final color = _getStatusColor(_networkStatus!);
    final icon = _getStatusIcon(_networkStatus!);

    return GestureDetector(
      onTap: _checkNetworkStatus,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 12),
            const SizedBox(width: 6),
            Text(
              _networkStatus!.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.healthy:
        return Colors.green;
      case NetworkStatus.noInternet:
        return Colors.red;
      case NetworkStatus.apiUnreachable:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.healthy:
        return Icons.wifi;
      case NetworkStatus.noInternet:
        return Icons.wifi_off;
      case NetworkStatus.apiUnreachable:
        return Icons.cloud_off;
    }
  }
}

/// Global error dialog for network-related issues
class NetworkErrorDialog extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const NetworkErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  static Future<void> show({
    required BuildContext context,
    required String error,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NetworkErrorDialog(
          error: error,
          onRetry: onRetry,
          onDismiss: onDismiss,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.wifi_off, color: Colors.red.shade600, size: 48),
      title: const Text('Connection Error'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (AppConfig.isDebugMode) ...[
            const SizedBox(height: 16),
            Text(
              'API: ${AppConfig.apiBaseUrl}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('Cancel'),
          ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text('Retry'),
          ),
        if (onRetry == null && onDismiss == null)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
      ],
    );
  }
}
