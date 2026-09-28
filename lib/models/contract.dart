class LegalContract {
  final int id;
  final int caseId;
  final String title;
  final String lawyerName;
  final double feeAmount;
  final String status; // draft | awaiting_signature | signed | cancelled

  LegalContract({
    required this.id,
    required this.caseId,
    required this.title,
    required this.lawyerName,
    required this.feeAmount,
    required this.status,
  });

  factory LegalContract.fromJson(Map<String, dynamic> json) => LegalContract(
        id: int.parse(json['id'].toString()),
        // A contract may not be attached to a case yet; `0` means "no case".
        caseId: int.tryParse('${json['case_id']}') ?? 0,
        title: json['title'] ?? '',
        lawyerName: json['lawyer_name'] ?? '',
        feeAmount: double.tryParse('${json['fee_amount']}') ?? 0,
        status: json['status'] ?? 'draft',
      );
}
