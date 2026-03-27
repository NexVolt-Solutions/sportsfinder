import 'package:flutter/material.dart';

// class CreateMatchScreenViewModel extends ChangeNotifier {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController _matchTitleController = TextEditingController();
//   TextEditingController get matchTitleController => _matchTitleController;

//   final TextEditingController _dateController = TextEditingController();
//   TextEditingController get dateController => _dateController;

//   final TextEditingController _timeController = TextEditingController();
//   TextEditingController get timeController => _timeController;

//   final TextEditingController _matchDurationController =
//       TextEditingController();
//   TextEditingController get matchDurationController => _matchDurationController;

//   final TextEditingController _locationController = TextEditingController();
//   TextEditingController get locationController => _locationController;

//   final TextEditingController _maxPlayersController = TextEditingController();
//   TextEditingController get maxPlayersController => _maxPlayersController;

//   final TextEditingController _skillLevelController = TextEditingController();
//   TextEditingController get skillLevelController => _skillLevelController;

//   final TextEditingController _sportTypeController = TextEditingController();
//   TextEditingController get sportTypeController => _sportTypeController;

//   final TextEditingController _descriptionController = TextEditingController();
//   TextEditingController get descriptionController => _descriptionController;

//   // Data
//   int _duration = 90; // in minutes
//   int get duration => _duration;

//   int _maxPlayers = 10;
//   int get maxPlayers => _maxPlayers;

//   DateTime? _selectedDate;
//   DateTime? get selectedDate => _selectedDate;

//   TimeOfDay? _selectedTime;
//   TimeOfDay? get selectedTime => _selectedTime;

//   final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

//   final List<String> sportTypes = [
//     'Football',
//     'Basketball',
//     'Cricket',
//     'Tennis',
//     'Volleyball',
//     'Badminton',
//   ];

//   // Methods
//   void setDate(DateTime date) {
//     _selectedDate = date;
//     _dateController.text =
//         '${date.day}/${_getMonthName(date.month)}/${date.year}';
//     notifyListeners();
//   }

//   void setTime(TimeOfDay time, BuildContext context) {
//     _selectedTime = time;
//     _timeController.text = time.format(context);
//     notifyListeners();
//   }

//   void incrementDuration() {
//     _duration += 15;
//     _matchDurationController.text = '$_duration minutes';
//     notifyListeners();
//   }

//   void decrementDuration() {
//     if (_duration > 15) {
//       _duration -= 15;
//       _matchDurationController.text = '$_duration minutes';
//       notifyListeners();
//     }
//   }

//   void incrementMaxPlayers() {
//     _maxPlayers++;
//     _maxPlayersController.text = _maxPlayers.toString();
//     notifyListeners();
//   }

//   void decrementMaxPlayers() {
//     if (_maxPlayers > 2) {
//       _maxPlayers--;
//       _maxPlayersController.text = _maxPlayers.toString();
//       notifyListeners();
//     }
//   }

//   void setSkillLevel(String level) {
//     _skillLevelController.text = level;
//     notifyListeners();
//   }

//   void setSportType(String sport) {
//     _sportTypeController.text = sport;
//     notifyListeners();
//   }

//   void createMatch() {
//     // Create match logic here
//     print('Match Title: ${_matchTitleController.text}');
//     print('Date: ${_dateController.text}');
//     print('Time: ${_timeController.text}');
//     print('Duration: $_duration minutes');
//     print('Location: ${_locationController.text}');
//     print('Max Players: $_maxPlayers');
//     print('Skill Level: ${_skillLevelController.text}');
//     print('Sport Type: ${_sportTypeController.text}');
//     print('Description: ${_descriptionController.text}');
//   }

//   String _getMonthName(int month) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[month - 1];
//   }

//   @override
//   void dispose() {
//     _matchTitleController.dispose();
//     _dateController.dispose();
//     _timeController.dispose();
//     _matchDurationController.dispose();
//     _locationController.dispose();
//     _maxPlayersController.dispose();
//     _skillLevelController.dispose();
//     _sportTypeController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }import 'package:flutter/material.dart';

class CreateMatchScreenViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // 🔤 Controllers (ONLY for text fields)
  final TextEditingController matchTitleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController matchDurationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController maxPlayersController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // 🔽 Dropdown Values
  String? selectedSkillLevel;
  String? selectedSportType;

  // 📊 Data
  int _duration = 90;
  int get duration => _duration;

  int _maxPlayers = 10;
  int get maxPlayers => _maxPlayers;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  TimeOfDay? _selectedTime;
  TimeOfDay? get selectedTime => _selectedTime;

  // 📋 Lists
  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  final List<String> sportTypes = [
    'Football',
    'Basketball',
    'Cricket',
    'Tennis',
    'Volleyball',
    'Badminton',
  ];

  // 📅 Date
  void setDate(DateTime date) {
    _selectedDate = date;
    dateController.text =
        '${date.day}/${_getMonthName(date.month)}/${date.year}';
    notifyListeners();
  }

  // ⏰ Time
  void setTime(TimeOfDay time, BuildContext context) {
    _selectedTime = time;
    timeController.text = time.format(context);
    notifyListeners();
  }

  // ⏱ Duration
  void incrementDuration() {
    _duration += 15;
    matchDurationController.text = '$_duration minutes';
    notifyListeners();
  }

  void decrementDuration() {
    if (_duration > 15) {
      _duration -= 15;
      matchDurationController.text = '$_duration minutes';
      notifyListeners();
    }
  }

  // 👥 Players
  void incrementMaxPlayers() {
    _maxPlayers++;
    maxPlayersController.text = _maxPlayers.toString();
    notifyListeners();
  }

  void decrementMaxPlayers() {
    if (_maxPlayers > 2) {
      _maxPlayers--;
      maxPlayersController.text = _maxPlayers.toString();
      notifyListeners();
    }
  }

  // 🔽 Dropdown Setters
  void setSkillLevel(String? level) {
    selectedSkillLevel = level;
    notifyListeners();
  }

  void setSportType(String? sport) {
    selectedSportType = sport;
    notifyListeners();
  }

  // 🚀 Create Match
  void createMatch() {
    print('Match Title: ${matchTitleController.text}');
    print('Date: ${dateController.text}');
    print('Time: ${timeController.text}');
    print('Duration: $_duration minutes');
    print('Location: ${locationController.text}');
    print('Max Players: $_maxPlayers');
    print('Skill Level: $selectedSkillLevel');
    print('Sport Type: $selectedSportType');
    print('Description: ${descriptionController.text}');
  }

  // 📅 Helper
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    matchTitleController.dispose();
    dateController.dispose();
    timeController.dispose();
    matchDurationController.dispose();
    locationController.dispose();
    maxPlayersController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
