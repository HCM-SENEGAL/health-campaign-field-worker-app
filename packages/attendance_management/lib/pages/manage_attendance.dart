import 'package:attendance_management/attendance_management.dart';
import 'package:digit_components/theme/colors.dart';
import 'package:digit_components/theme/digit_theme.dart';
import 'package:digit_components/utils/date_utils.dart';
import 'package:digit_components/widgets/digit_card.dart';
import 'package:digit_components/widgets/digit_elevated_button.dart';
import 'package:digit_components/widgets/molecules/digit_table_card.dart';
import 'package:digit_components/widgets/powered_by_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/localized.dart';

class ManageAttendancePage extends LocalizedStatefulWidget {
  final AttendanceListeners attendanceListeners;
  const ManageAttendancePage({
    required this.attendanceListeners,
    super.key,
    super.appLocalizations,
  });

  @override
  State<ManageAttendancePage> createState() => _ManageAttendancePageState();
}

class _ManageAttendancePageState extends State<ManageAttendancePage> {
  List<AttendancePackageRegisterModel> attendanceRegisters = [];

  bool empty = false;
  AttendanceBloc attendanceBloc = AttendanceBloc(const RegisterLoading());

  @override
  void initState() {
    AttendanceSingleton().setAttendanceListeners(widget.attendanceListeners);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    return BlocProvider<AttendanceBloc>(
      create: (context) =>
          attendanceBloc..add(const AttendanceEvents.initial()),
      child: BlocListener<AttendanceBloc, AttendanceStates>(
        listener: (ctx, states) {
          if (states is RegisterLoaded) {
            attendanceRegisters = states.registers;
            for (int i = 0; i < attendanceRegisters.length; i++) {
              final register = attendanceRegisters[i];
              list.add(RegisterCard(
                  data: {
                    'Campaign Type': register.name,
                    'Event Type': register.serviceCode,
                    'Staff Count': 15,
                    'Start Date': register.startDate != null
                        ? DigitDateUtils.getDateFromTimestamp(
                            register.startDate!)
                        : 'N/A',
                    'End Date': register.endDate != null
                        ? DigitDateUtils.getDateFromTimestamp(register.endDate!)
                        : 'N/A',
                    'Status': register.status,
                    'Attendance Completion': 'N/A'
                  },
                  regisId: register.id,
                  tenantId: register.tenantId!,
                  show: true,
                  startDate: DateTime.fromMillisecondsSinceEpoch(
                    register.startDate!,
                  ),
                  endDate: DateTime.fromMillisecondsSinceEpoch(
                    register.endDate!,
                  )));
            }
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(child:
              BlocBuilder<AttendanceBloc, AttendanceStates>(
                  builder: (context, blocState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Manage Attendance",
                    style: DigitTheme
                        .instance.mobileTheme.textTheme.headlineLarge
                        ?.apply(color: const DigitColors().black),
                    textAlign: TextAlign.left,
                  ),
                ),
                empty
                    ? const Center(
                        child: Card(
                          child: SizedBox(
                            height: 60,
                            width: 200,
                            child: Center(child: Text("No Data Found")),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                blocState.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  registerLoaded: (registers) => Column(
                    children: [
                      ...list,
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: PoweredByDigit(
                    version: '1.2.0',
                  ),
                ),
              ],
            );
          })),
        ),
      ),
    );
  }
}

class RegisterCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String tenantId;
  final String regisId;
  final bool show;
  final DateTime startDate;
  final DateTime endDate;

  const RegisterCard({
    super.key,
    required this.data,
    required this.tenantId,
    required this.regisId,
    this.show = false,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    DateTime s = DateTime.now();

    return DigitCard(
      child: Column(
        children: [
          DigitTableCard(
            element: data,
          ),
          show
              ? DigitElevatedButton(
                  child: Text(
                    ((s.isAfter(startDate) || s.isAtSameMomentAs(startDate)) &&
                            (s.isBefore(endDate) ||
                                s.isAtSameMomentAs(endDate)))
                        ? 'Mark Attendance'
                        : 'View Attendance',
                  ),
                  onPressed: () {},
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
