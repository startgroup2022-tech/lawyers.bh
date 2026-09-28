import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'contract_payment_screen.dart';
import 'login_otp_screen.dart';

const _consultTypes = [
  {'key': 'video', 'label': 'فيديو', 'icon': Icons.videocam_outlined},
  {'key': 'voice', 'label': 'صوتي', 'icon': Icons.mic_none_outlined},
  {'key': 'inperson', 'label': 'حضوري', 'icon': Icons.work_outline},
];

class LawyerProfileScreen extends StatefulWidget {
  final int lawyerId;
  const LawyerProfileScreen({super.key, required this.lawyerId});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  late Future<Lawyer> _future;
  String _consultType = 'video';
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _future = context.read<AppState>().lawyers.detail(widget.lawyerId);
  }

  Future<void> _bookConsultation(Lawyer lawyer) async {
    final appState = context.read<AppState>();
    if (!appState.isLoggedIn) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginOtpScreen()));
      return;
    }
    setState(() => _booking = true);
    try {
      final (caseId, contractId) = await appState.cases.bookConsultation(
        lawyerId: lawyer.id,
        consultType: _consultType,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ContractPaymentScreen(contractId: contractId, caseId: caseId)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر إتمام الحجز، حاول مرة أخرى')));
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<Lawyer>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SafeArea(child: Center(child: CircularProgressIndicator()));
          }
          final l = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFCBD5E1)),
                              const SizedBox(width: 6),
                              Text('رجوع', style: AppTextStyles.tajawal(size: 13, color: const Color(0xFFCBD5E1))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Colors.white,
                            child: Text(l.initials,
                                style: AppTextStyles.cairo(size: 20, weight: FontWeight.w800, color: AppColors.navy)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(l.name,
                              style: AppTextStyles.cairo(size: 16, weight: FontWeight.w800, color: Colors.white)),
                        ),
                        const SizedBox(height: 3),
                        Center(
                          child: Text('${l.categoryName} · ${l.location}',
                              style: AppTextStyles.tajawal(size: 11.5, color: const Color(0xFFC9D3E4))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(
                        children: [
                          _stat('★ ${l.rating}', '${l.reviewsCount} تقييم'),
                          _stat('${l.experienceYears}', 'سنة خبرة'),
                          _stat('${l.consultationFee.toStringAsFixed(0)} د.ب', 'الاستشارة'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: l.tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.bg,
                                        border: Border.all(color: AppColors.line),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(t,
                                          style: AppTextStyles.tajawal(size: 11, color: AppColors.navyLight)),
                                    ))
                                .toList(),
                          ),
                          if (l.bio != null) ...[
                            const SizedBox(height: 10),
                            Text(l.bio!, style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2, height: 1.7)),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _contactBtn(Icons.call_outlined, 'اتصال'),
                              _contactBtn(Icons.chat_bubble_outline, 'واتساب'),
                              _contactBtn(Icons.mail_outline, 'مراسلة'),
                              _contactBtn(Icons.bookmark_border, 'حفظ'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('نوع الاستشارة', style: AppTextStyles.cairo(size: 14.5, weight: FontWeight.w800, color: AppColors.navy)),
                    const SizedBox(height: 10),
                    Row(
                      children: _consultTypes.map((c) {
                        final selected = _consultType == c['key'];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onTap: () => setState(() => _consultType = c['key'] as String),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.navy : Colors.white,
                                  border: Border.all(color: selected ? AppColors.navy : AppColors.line),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Icon(c['icon'] as IconData, size: 16, color: selected ? Colors.white : AppColors.ink2),
                                    const SizedBox(height: 3),
                                    Text(c['label'] as String,
                                        style: AppTextStyles.tajawal(
                                            size: 11, color: selected ? Colors.white : AppColors.ink2)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _booking ? null : () => _bookConsultation(l),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimson),
                      icon: _booking
                          ? const SizedBox(
                              height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('احجز استشارة'),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.cairo(size: 15, weight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.tajawal(size: 9.5, color: AppColors.ink3)),
        ],
      ),
    );
  }

  Widget _contactBtn(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 19, color: AppColors.navyLight),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.tajawal(size: 10, color: AppColors.ink2)),
      ],
    );
  }
}
