import 'dart:math';

import 'package:collection/collection.dart';
import 'package:digit_components/widgets/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_repository.dart';
import '../../data/repositories/local/project_beneficiary.dart';
import '../../data/repositories/local/task.dart';
import '../../models/data_model.dart';
import '../../utils/utils.dart';
import '../progress_indicator/progress_indicator.dart';

class BeneficiaryProgressBar extends StatefulWidget {
  final String label;
  final String prefixLabel;

  const BeneficiaryProgressBar({
    Key? key,
    required this.label,
    required this.prefixLabel,
  }) : super(key: key);

  @override
  State<BeneficiaryProgressBar> createState() => _BeneficiaryProgressBarState();
}

class _BeneficiaryProgressBarState extends State<BeneficiaryProgressBar> {
  int current = 0;

  @override
  void didChangeDependencies() {
    final taskRepository =
        context.read<LocalRepository<TaskModel, TaskSearchModel>>()
            as TaskLocalRepository;

    final projectBeneficiaryRepository = context.read<
            LocalRepository<ProjectBeneficiaryModel,
                ProjectBeneficiarySearchModel>>()
        as ProjectBeneficiaryLocalRepository;

    final now = DateTime.now();
    final gte = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final lte = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
      999,
    );

    taskRepository.listenToChanges(
      query: TaskSearchModel(
        projectId: context.projectId,
        createdBy: context.loggedInUserUuid,
        plannedEndDate: lte.millisecondsSinceEpoch,
        plannedStartDate: gte.millisecondsSinceEpoch,
      ),
      listener: (data) async {
        if (mounted) {
          final groupedEntries = data.groupListsBy(
            (element) => element.projectBeneficiaryClientReferenceId,
          );
          Set<String?> projectBeneficiaryClientReferenceIdsTask = {};

          final projectBeneficiaries =
              await projectBeneficiaryRepository.search(
            ProjectBeneficiarySearchModel(
              beneficiaryRegistrationDateLte:
                  DateTime.fromMillisecondsSinceEpoch(
                lte.millisecondsSinceEpoch,
              ),
              beneficiaryRegistrationDateGte:
                  DateTime.fromMillisecondsSinceEpoch(
                gte.millisecondsSinceEpoch,
              ),
            ),
            context.loggedInUserUuid,
          );

          projectBeneficiaryClientReferenceIdsTask.addAll(projectBeneficiaries
              .map(
                (e) => e.clientReferenceId,
              )
              .toSet());

          projectBeneficiaryClientReferenceIdsTask
              .addAll(groupedEntries.keys.toSet());

          setState(() {
            if (mounted) {
              current = projectBeneficiaryClientReferenceIdsTask.length;
            }
          });
        }
      },
    );

    projectBeneficiaryRepository.listenToChanges(
      query: ProjectBeneficiarySearchModel(
        projectId: context.projectId,
        beneficiaryRegistrationDateLte:
            DateTime.fromMillisecondsSinceEpoch(lte.millisecondsSinceEpoch),
        beneficiaryRegistrationDateGte:
            DateTime.fromMillisecondsSinceEpoch(gte.millisecondsSinceEpoch),
      ),
      userId: context.loggedInUserUuid,
      listener: (data) async {
        if (mounted) {
          final entries = data
              .map(
                (element) => element.clientReferenceId,
              )
              .toSet();
          Set<String?> projectBeneficiaryClientReferenceIds = {};
          projectBeneficiaryClientReferenceIds.addAll(entries);

          final tasks = await taskRepository.search(TaskSearchModel(
            projectId: context.projectId,
            createdBy: context.loggedInUserUuid,
            plannedEndDate: lte.millisecondsSinceEpoch,
            plannedStartDate: gte.millisecondsSinceEpoch,
          ));

          final groupedTasks = tasks.groupListsBy(
            (element) => element.projectBeneficiaryClientReferenceId,
          );

          projectBeneficiaryClientReferenceIds
              .addAll(groupedTasks.keys.toSet());

          setState(() {
            if (mounted) {
              current = projectBeneficiaryClientReferenceIds.length;
            }
          });
        }
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Solution Customization
    // final selectedProject = context.selectedProject;
    // final beneficiaryType = context.beneficiaryType;

    // final targetModel = selectedProject.targets?.firstWhereOrNull(
    //   (element) => element.beneficiaryType == beneficiaryType,
    // );

    final target = 70;

    return DigitCard(
      child: ProgressIndicatorContainer(
        label: '${max(target - current, 0).round()} ${widget.label}',
        prefixLabel: '$current ${widget.prefixLabel}',
        suffixLabel: target.toStringAsFixed(0),
        value: target == 0 ? 0 : min(current / target, 1),
      ),
    );
  }
}
