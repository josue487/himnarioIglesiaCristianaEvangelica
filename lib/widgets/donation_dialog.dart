import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

class DonationDialog extends StatelessWidget {
  final VoidCallback onDonated;
  final bool soft;

  const DonationDialog({super.key, required this.onDonated, this.soft = false});

  void _copyAlias(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: kDonationAlias));
    Navigator.pop(context);
    onDonated();
  }

  Future<void> _openPaypal(BuildContext context) async {
    Navigator.pop(context);
    await launchUrl(Uri.parse(kDonationPaypalUrl), mode: LaunchMode.externalApplication);
    onDonated();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Colaborar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  soft
                      ? 'Himnario ICE es gratuito y sin anuncios, y se mantiene con el esfuerzo de una sola persona. '
                          'Si esta app te acompana en tus momentos de alabanza, tu colaboracion voluntaria ayuda a '
                          'mantenerla, actualizarla y llegar a mas hermanos. Gracias y Dios te bendiga!'
                      : 'Esta app es gratuita. Si te resulta util, podes colaborar voluntariamente.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 20),
                // Argentina
                _DonationOption(
                  icon: Icons.account_balance_outlined,
                  region: 'Argentina',
                  detail: kDonationAlias,
                  buttonLabel: 'Copiar alias',
                  buttonIcon: Icons.copy_outlined,
                  onTap: () => _copyAlias(context),
                ),
                const Divider(height: 24),
                // Internacional
                _DonationOption(
                  icon: Icons.public_outlined,
                  region: 'Internacional',
                  detail: '@josue487pp  (PayPal)',
                  buttonLabel: 'Abrir PayPal',
                  buttonIcon: Icons.open_in_new,
                  onTap: () => _openPaypal(context),
                ),
                if (soft)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Ahora no',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationOption extends StatelessWidget {
  final IconData icon;
  final String region;
  final String detail;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onTap;

  const _DonationOption({
    required this.icon,
    required this.region,
    required this.detail,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.indigo.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                region,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.indigo.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onTap,
          icon: Icon(buttonIcon, size: 15),
          label: Text(buttonLabel, style: const TextStyle(fontSize: 13)),
          style: TextButton.styleFrom(
            foregroundColor: Colors.indigo.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }
}
