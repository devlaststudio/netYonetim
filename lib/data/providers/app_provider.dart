import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/due_model.dart';
import '../models/ticket_model.dart';
import '../models/announcement_model.dart';
import '../models/payment_model.dart';
import '../models/visitor_model.dart';
import '../models/technician_model.dart';
import '../models/service_request_model.dart';
import '../models/poll_model.dart';
import '../models/facility_model.dart';
import '../models/reservation_model.dart';
import '../models/site_model.dart';
import '../mock/mock_data.dart';

class AppProvider extends ChangeNotifier {
  // State
  bool _isLoggedIn = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  List<DueModel> _dues = [];
  List<DueModel> _paidDues = [];
  List<TicketModel> _tickets = [];
  List<AnnouncementModel> _announcements = [];
  List<PaymentModel> _payments = [];
  List<VisitorModel> _visitors = [];
  List<TechnicianModel> _technicians = [];
  List<ServiceRequestModel> _serviceRequests = [];
  List<PollModel> _polls = [];
  List<FacilityModel> _facilities = [];
  List<ReservationModel> _reservations = [];
  int _currentNavIndex = 0;
  List<SiteModel> _managedSites = [];
  SiteModel? _selectedSite;
  bool _needsSiteSelection = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  List<DueModel> get dues => _dues;
  List<DueModel> get paidDues => _paidDues;
  List<DueModel> get openDues => _dues.where((d) => !d.isPaid).toList();
  List<DueModel> get overdueDues => _dues.where((d) => d.isOverdue).toList();
  List<TicketModel> get tickets => _tickets;
  List<AnnouncementModel> get announcements => _announcements;
  List<PaymentModel> get payments => _payments;
  List<VisitorModel> get visitors => _visitors;
  List<VisitorModel> get expectedVisitors =>
      _visitors.where((v) => v.status == VisitorStatus.expected).toList();
  List<VisitorModel> get activeVisitors =>
      _visitors.where((v) => v.status == VisitorStatus.inside).toList();
  List<VisitorModel> get pastVisitors => _visitors
      .where(
        (v) =>
            v.status == VisitorStatus.left ||
            v.status == VisitorStatus.cancelled,
      )
      .toList();
  List<TechnicianModel> get technicians => _technicians;
  List<ServiceRequestModel> get serviceRequests => _serviceRequests;
  List<PollModel> get polls => _polls;
  List<FacilityModel> get facilities => _facilities;
  List<ReservationModel> get reservations => _reservations;
  int get currentNavIndex => _currentNavIndex;
  List<SiteModel> get managedSites => _managedSites;
  SiteModel? get selectedSite => _selectedSite;
  bool get needsSiteSelection => _needsSiteSelection;
  String get selectedSiteName => _selectedSite?.name ?? MockData.siteName;

  double get totalDebt =>
      openDues.fold<double>(0, (sum, due) => sum + due.remainingAmount);
  double get totalPaid =>
      paidDues.fold<double>(0, (sum, due) => sum + due.amount);
  int get unreadAnnouncementsCount =>
      announcements.where((a) => !a.isRead).length;
  int get openTicketsCount =>
      tickets.where((t) => t.status == TicketStatus.open).length;

  // Role Checks
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isManager => _currentUser?.role == UserRole.manager;
  bool get canAccessAccounting => isAdmin || isManager;

  // Auth Actions
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Demo login - check email to determine user role
    if (email.isNotEmpty && password.isNotEmpty) {
      // Check which user to login as based on email
      if (email.toLowerCase().contains('admin')) {
        _currentUser = MockData.demoAdmin;
      } else if (email.toLowerCase().contains('manager') ||
          email.toLowerCase().contains('yonetici')) {
        _currentUser = MockData.demoManager;
      } else {
        _currentUser = MockData.demoUser;
      }

      _isLoggedIn = true;

      // Admin/Manager ise yetkili siteleri yükle
      if (canAccessAccounting) {
        _managedSites = MockData.getManagedSites();
        if (_managedSites.length > 1) {
          _needsSiteSelection = true;
          _isLoading = false;
          notifyListeners();
          return true;
        } else if (_managedSites.length == 1) {
          _selectedSite = _managedSites.first;
        }
      }

      await _loadInitialData();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Site seçildikten sonra çağrılır
  Future<void> selectSite(SiteModel site) async {
    _selectedSite = site;
    _needsSiteSelection = false;
    _isLoading = true;
    notifyListeners();

    await _loadInitialData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _dues = [];
    _paidDues = [];
    _tickets = [];
    _announcements = [];
    _payments = [];
    _visitors = [];
    _technicians = [];
    _serviceRequests = [];
    _currentNavIndex = 0;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    _dues = MockData.getDues();
    _paidDues = MockData.getPaidDues();
    _tickets = MockData.getTickets(); // Load Data
    _announcements = MockData.getAnnouncements();
    _payments = MockData.getPayments();
    _visitors = MockData.getVisitors();
    _technicians = MockData.getTechnicians();

    // Load persisted service requests
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getStringList('service_requests');
    if (requestsJson != null) {
      _serviceRequests = requestsJson
          .map((str) => ServiceRequestModel.fromJson(str))
          .toList();
    } else {
      _serviceRequests = MockData.getServiceRequests();
    }

    // Load Polls
    // In a real app we'd load user's voting status too
    final pollsJson = prefs.getStringList('polls'); // Persisted polls
    if (pollsJson != null) {
      _polls = pollsJson.map((str) => PollModel.fromJson(str)).toList();
    } else {
      _polls = MockData.getPolls();
    }

    // Load Facilities and Reservations
    _facilities = MockData.getFacilities();
    // In real app, load from API/Storage
    _reservations = MockData.getReservations();
  }

  // Navigation
  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // Dues Actions
  Future<bool> payDue(DueModel due, PaymentMethod method) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Calculate commission
    double commission = 0;
    if (method == PaymentMethod.creditCard) {
      commission = due.remainingAmount * 0.0189;
    }

    // Create payment record
    final payment = PaymentModel(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      dueId: due.id,
      userId: _currentUser!.id,
      amount: due.remainingAmount,
      method: method,
      status: PaymentStatus.completed,
      paymentDate: DateTime.now(),
      transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      commissionAmount: commission,
      description: due.description,
    );
    _payments.insert(0, payment);

    // Update due status
    final index = _dues.indexWhere((d) => d.id == due.id);
    if (index != -1) {
      final updatedDue = _dues[index].copyWith(
        status: DueStatus.paid,
        paidAmount: _dues[index].amount + (_dues[index].delayFee ?? 0),
        paidDate: DateTime.now(),
      );
      _dues.removeAt(index);
      _paidDues.insert(0, updatedDue);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> payAllDues(PaymentMethod method) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    for (final due in List.from(openDues)) {
      double commission = 0;
      if (method == PaymentMethod.creditCard) {
        commission = due.remainingAmount * 0.0189;
      }

      final payment = PaymentModel(
        id: 'pay-${DateTime.now().millisecondsSinceEpoch}-${due.id}',
        dueId: due.id,
        userId: _currentUser!.id,
        amount: due.remainingAmount,
        method: method,
        status: PaymentStatus.completed,
        paymentDate: DateTime.now(),
        transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        commissionAmount: commission,
        description: due.description,
      );
      _payments.insert(0, payment);

      final updatedDue = due.copyWith(
        status: DueStatus.paid,
        paidAmount: due.amount + (due.delayFee ?? 0),
        paidDate: DateTime.now(),
      );
      _dues.removeWhere((d) => d.id == due.id);
      _paidDues.insert(0, updatedDue);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Ticket Actions
  Future<TicketModel> createTicket({
    required TicketCategory category,
    required TicketPriority priority,
    required String title,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final ticket = TicketModel(
      id: 'ticket-${DateTime.now().millisecondsSinceEpoch}',
      siteId: _currentUser!.siteId!,
      userId: _currentUser!.id,
      userName: _currentUser!.fullName,
      unitNo: '${_currentUser!.blockName}-${_currentUser!.unitNo}',
      category: category,
      priority: priority,
      title: title,
      description: description,
      status: TicketStatus.open,
      createdAt: DateTime.now(),
    );

    _tickets.insert(0, ticket);
    _isLoading = false;
    notifyListeners();
    return ticket;
  }

  Future<void> addTicketComment(String ticketId, String content) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final comment = TicketComment(
        id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
        ticketId: ticketId,
        userId: _currentUser!.id,
        userName: _currentUser!.fullName,
        content: content,
        createdAt: DateTime.now(),
        isStaff: false,
      );

      final updatedComments = [..._tickets[index].comments, comment];
      _tickets[index] = _tickets[index].copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  // Announcement Actions
  void markAnnouncementAsRead(String announcementId) {
    final index = _announcements.indexWhere((a) => a.id == announcementId);
    if (index != -1) {
      _announcements[index] = _announcements[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Visitor Actions
  Future<void> addVisitor({
    required String guestName,
    String? plateNumber,
    required DateTime expectedDate,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final visitor = VisitorModel(
      id: 'vis-${DateTime.now().millisecondsSinceEpoch}',
      residentId: _currentUser!.id,
      guestName: guestName,
      plateNumber: plateNumber,
      expectedDate: expectedDate,
      status: VisitorStatus.expected,
      note: note,
    );

    _visitors.insert(0, visitor);
    _isLoading = false;
    notifyListeners();
  }

  // Service Actions
  Future<void> createServiceRequest({
    required String technicianId,
    required String categoryId,
    required String description,
    required DateTime appointmentDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final request = ServiceRequestModel(
      id: 'sr-${DateTime.now().millisecondsSinceEpoch}',
      residentId: _currentUser!.id,
      technicianId: technicianId,
      categoryId: categoryId,
      description: description,
      status: ServiceRequestStatus.pending,
      requestDate: DateTime.now(),
      appointmentDate: appointmentDate,
    );

    _serviceRequests.insert(0, request);

    // Persist
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = _serviceRequests.map((r) => r.toJson()).toList();
    await prefs.setStringList('service_requests', requestsJson);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateServiceRequest({
    required String requestId,
    required ServiceRequestStatus status,
    double? rating,
    String? reviewComment,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _serviceRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      // Create updated copy
      // Since model is final, we need to recreate it.
      // Ideally we should have copyWith method but for now:
      final old = _serviceRequests[index];
      final updated = ServiceRequestModel(
        id: old.id,
        residentId: old.residentId,
        technicianId: old.technicianId,
        categoryId: old.categoryId,
        description: old.description,
        status: status, // Updated status
        requestDate: old.requestDate,
        appointmentDate: old.appointmentDate,
        photos: old.photos,
        rating: rating ?? old.rating, // Updated rating
        reviewComment: reviewComment ?? old.reviewComment, // Updated comment
      );

      _serviceRequests[index] = updated;

      // Persist
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = _serviceRequests.map((r) => r.toJson()).toList();
      await prefs.setStringList('service_requests', requestsJson);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    await _loadInitialData();

    _isLoading = false;
    notifyListeners();
  }

  // Polls
  Future<void> votePoll({
    required String pollId,
    required String optionId,
  }) async {
    final pollIndex = _polls.indexWhere((p) => p.id == pollId);
    if (pollIndex == -1) return;

    final poll = _polls[pollIndex];
    if (poll.hasVoted || !poll.isActive) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    // Update vote count
    final updatedOptions = poll.options.map((opt) {
      if (opt.id == optionId) {
        return PollOption(
          id: opt.id,
          text: opt.text,
          voteCount: opt.voteCount + 1,
        );
      }
      return opt;
    }).toList();

    // Create updated poll
    final updatedPoll = PollModel(
      id: poll.id,
      title: poll.title,
      description: poll.description,
      options: updatedOptions,
      endDate: poll.endDate,
      isActive: poll.isActive,
      hasVoted: true,
      selectedOptionId: optionId,
    );

    _polls[pollIndex] = updatedPoll;

    // Persist
    final prefs = await SharedPreferences.getInstance();
    final pollsJson = _polls.map((p) => p.toJson()).toList();
    await prefs.setStringList('polls', pollsJson);

    _isLoading = false;
    notifyListeners();
  }

  // Reservation
  Future<bool> makeReservation({
    required FacilityModel facility,
    required DateTime startTime,
    required int durationMinutes,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Simple conflict check (Mock)
    // In real app, check against all reservations for that facility
    final hasConflict = _reservations.any(
      (r) =>
          r.facilityId == facility.id &&
          r.status == ReservationStatus.active &&
          r.startTime.isAtSameMomentAs(startTime),
    );

    if (hasConflict) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final reservation = ReservationModel(
      id: 'res-${DateTime.now().millisecondsSinceEpoch}',
      facilityId: facility.id,
      facilityName: facility.name,
      residentId: _currentUser!.id,
      startTime: startTime,
      durationMinutes: durationMinutes,
      status: ReservationStatus.active,
      note: note,
    );

    _reservations.insert(0, reservation);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> cancelReservation(String reservationId) async {
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index == -1) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final old = _reservations[index];
    final updated = ReservationModel(
      id: old.id,
      facilityId: old.facilityId,
      facilityName: old.facilityName,
      residentId: old.residentId,
      startTime: old.startTime,
      durationMinutes: old.durationMinutes,
      status: ReservationStatus.cancelled,
      note: old.note,
    );

    _reservations[index] = updated;

    _isLoading = false;
    notifyListeners();
  }
}
