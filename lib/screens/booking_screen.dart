import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../models/consultation_method.dart';
import '../models/lawyer.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_widgets.dart';
import '../widgets/section_title.dart';
import '../widgets/state_views.dart';

/// The real booking flow: pick a consultation method, a date, then one of the
/// lawyer's free slots, add an optional note, and book.
///
/// Every step is backed by an existing platform route. The slot list comes from
/// `GET /api/mobile/lawyers/{id}/availability` and the booking is written by
/// `POST /api/mobile/client-appointments`, which recomputes availability inside
/// its transaction — so a slot that was taken while the client was deciding is
/// rejected by the backend rather than silently double-booked.
class BookingScreen extends StatefulWidget {
  final Lawyer lawyer;

  /// When opened from a home "voice/video" action, the method whose code
  /// matches is pre-selected so the shortcut lands on the right flow.
  final String? initialMethodCode;

  const BookingScreen({super.key, required this.lawyer, this.initialMethodCode});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _dates = upcomingDates();

  List<ConsultationMethod> _methods = const [];
  ConsultationMethod? _method;
  DateTime _date = DateTime.now();
  List<AvailableSlot> _slots = const [];
  String? _selectedStart;
  String? _selectedEnd;

  bool _loadingMethods = true;
  bool _loadingSlots = false;
  bool _booking = false;
  String? _methodsError;
  String? _slotsError;

  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateUtils.dateOnly(DateTime.now());
    _loadMethods();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadMethods() async {
    setState(() {
      _loadingMethods = true;
      _methodsError = null;
    });
    final service = context.read<AppState>().appointments;
    try {
      final methods = await loadConsultationMethods(
        () => service.consultationMethods(countryCode: widget.lawyer.countryCode),
      );
      if (!mounted) return;
      setState(() {
        _methods = methods;
        _method = _pickInitialMethod(methods);
      });
      await _loadSlots();
    } on ApiException catch (e) {
      if (mounted) setState(() => _methodsError = e.message ?? 'تعذّر تحميل أنواع الاستشارة');
    } catch (_) {
      if (mounted) setState(() => _methodsError = 'تعذّر تحميل أنواع الاستشارة');
    } finally {
      if (mounted) setState(() => _loadingMethods = false);
    }
  }

  ConsultationMethod? _pickInitialMethod(List<ConsultationMethod> methods) {
    if (methods.isEmpty) return null;
    final wanted = widget.initialMethodCode;
    if (wanted != null) {
      for (final m in methods) {
        if (m.code == wanted) return m;
      }
      // Voice shortcuts accept either telephony channel.
      if (wanted == 'phone') {
        for (final m in methods) {
          if (m.isVoice) return m;
        }
      }
    }
    return methods.first;
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _slots = const [];
      _selectedStart = null;
      _selectedEnd = null;
    });
    final service = context.read<AppState>().appointments;
    try {
      final slots = await service.availableSlots(
        lawyerId: widget.lawyer.id,
        date: apiDate(_date),
        countryCode: widget.lawyer.countryCode,
      );
      if (mounted) setState(() => _slots = slots);
    } on ApiException catch (e) {
      if (mounted) setState(() => _slotsError = e.message ?? 'تعذّر تحميل الأوقات المتاحة');
    } catch (_) {
      if (mounted) setState(() => _slotsError = 'تعذّر تحميل الأوقات المتاحة');
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  void _selectSlot(String start) {
    AvailableSlot? match;
    for (final s in _slots) {
      if (s.start == start) {
        match = s;
        break;
      }
    }
    if (match == null) return;
    setState(() {
      _selectedStart = match!.start;
      _selectedEnd = match.end;
    });
  }

  Future<void> _book() async {
    final method = _method;
    final start = _selectedStart;
    final end = _selectedEnd;
    if (method == null || start == null || end == null) return;

    setState(() => _booking = true);
    final service = context.read<AppState>().appointments;
    try {
      final appointment = await service.book(
        lawyerId: widget.lawyer.id,
        date: apiDate(_date),
        startTime: start,
        endTime: end,
        consultationMethod: method.code,
        countryCode: widget.lawyer.countryCode,
        notes: _notes.text,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            appointment: appointment,
            lawyerName: widget.lawyer.name,
            methodName: method.name,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      // A slot conflict is authoritative: refresh the list so the client sees
      // what is actually free before retrying.
      final conflict = e.error == 'slot_taken' || e.error == 'slot_unavailable';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_bookingError(e)),
      ));
      if (conflict) await _loadSlots();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذّر إتمام الحجز')));
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  String _bookingError(ApiException e) {
    switch (e.error) {
      case 'slot_taken':
        return 'هذا الوقت لم يعد متاحًا، اختر وقتًا آخر';
      case 'slot_unavailable':
        return 'هذا الوقت لم يعد متاحًا، اختر وقتًا آخر';
      case 'lawyer_not_found':
        return 'المحامي غير متاح للحجز حاليًا';
      case 'invalid_consultation_method':
        return 'نوع الاستشارة غير متاح';
      case 'unauthorized':
        return 'سجّل دخولك لإتمام الحجز';
      default:
        return e.message ?? 'تعذّر إتمام الحجز';
    }
  }

  bool get _canBook => _method != null && _selectedStart != null && !_booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز موعد')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _lawyerHeader(),
            const SizedBox(height: 18),
            const SectionTitle(title: 'نوع الاستشارة'),
            if (_loadingMethods)
              const LoadingState(label: 'جارٍ تحميل أنواع الاستشارة…')
            else if (_methodsError != null)
              ErrorState(message: _methodsError!, onRetry: _loadMethods)
            else
              ..._methods.map((m) => ConsultationMethodTile(
                    method: m,
                    selected: m.code == _method?.code,
                    onTap: () => setState(() => _method = m),
                  )),
            const SizedBox(height: 14),
            const SectionTitle(title: 'التاريخ'),
            DateStrip(
              dates: _dates,
              selected: _date,
              onSelected: (date) {
                setState(() => _date = date);
                _loadSlots();
              },
            ),
            const SizedBox(height: 14),
            const SectionTitle(title: 'الأوقات المتاحة'),
            if (_loadingSlots)
              const LoadingState(label: 'جارٍ تحميل الأوقات…')
            else if (_slotsError != null)
              ErrorState(message: _slotsError!, onRetry: _loadSlots)
            else
              SlotGrid(
                starts: _slots.map((s) => s.start).toList(growable: false),
                selected: _selectedStart,
                onSelected: _selectSlot,
              ),
            const SizedBox(height: 18),
            const SectionTitle(title: 'ملاحظات (اختياري)'),
            TextField(
              controller: _notes,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'اكتب ملخصًا موجزًا لاستشارتك…',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _canBook ? _book : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _booking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Text('تأكيد الحجز'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lawyerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.brandDark,
            child: Text(widget.lawyer.initials,
                style: AppTextStyles.cairo(
                    size: 14, weight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.lawyer.name,
                    style: AppTextStyles.cairo(size: 14, weight: FontWeight.w700)),
                if ((widget.lawyer.professionalTitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(widget.lawyer.professionalTitle!,
                      style: AppTextStyles.tajawal(size: 11.5, color: AppColors.ink2)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The post-booking receipt. Shows only what the backend confirmed.
class BookingConfirmationScreen extends StatelessWidget {
  final ClientAppointment appointment;
  final String lawyerName;
  final String methodName;

  const BookingConfirmationScreen({
    super.key,
    required this.appointment,
    required this.lawyerName,
    required this.methodName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تم الحجز')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                    color: AppColors.greenBg, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 34, color: AppColors.green),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('تم تأكيد حجزك',
                  style: AppTextStyles.cairo(size: 16, weight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('سيتم التواصل معك لتأكيد التفاصيل',
                  style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2)),
            ),
            const SizedBox(height: 22),
            _detailCard(),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          _row('المحامي', lawyerName),
          const SizedBox(height: 12),
          _row('نوع الاستشارة', methodName),
          const SizedBox(height: 12),
          _row('التاريخ', appointment.date),
          const SizedBox(height: 12),
          _row('الوقت', appointment.timeRange),
          if (appointment.durationMinutes > 0) ...[
            const SizedBox(height: 12),
            _row('المدة', '${appointment.durationMinutes} دقيقة'),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.tajawal(size: 12.5, color: AppColors.ink2)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.end,
              style: AppTextStyles.cairo(size: 12.5, weight: FontWeight.w700)),
        ),
      ],
    );
  }
}
