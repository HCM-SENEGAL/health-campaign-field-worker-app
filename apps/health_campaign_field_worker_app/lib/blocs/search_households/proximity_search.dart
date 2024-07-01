import 'dart:async';

import 'package:collection/collection.dart';
import 'search_households.dart';
import '../../models/entities/address.dart';
import '../../models/entities/beneficiary_type.dart';
import '../../models/entities/household.dart';
import '../../models/entities/household_member.dart';
import '../../models/entities/individual.dart';
import '../../models/entities/project_beneficiary.dart';
import '../../models/entities/referral.dart';
import '../../models/entities/side_effect.dart';
import '../../models/entities/task.dart';

class ProximitySearchBloc extends SearchHouseholdsBloc {
  ProximitySearchBloc({
    required super.userUid,
    required super.projectId,
    required super.individual,
    required super.householdMember,
    required super.household,
    required super.projectBeneficiary,
    required super.taskDataRepository,
    required super.beneficiaryType,
    required super.sideEffectDataRepository,
    required super.addressRepository,
    required super.referralDataRepository,
  }) {
    on<SearchHouseholdsByProximityEvent>(_handleSearchByProximity);
  }

  FutureOr<void> _handleSearchByProximity(
    SearchHouseholdsByProximityEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    List<HouseholdModel> householdList = [];
    List<IndividualModel> individualsList = [];
    List<HouseholdMemberModel> householdMembersList = [];
    List<ProjectBeneficiaryModel> projectBeneficiariesList = [];
    List<TaskModel> taskList = [];
    List<SideEffectModel> sideEffectsList = [];
    List<ReferralModel> referralsList = [];
    emit(state.copyWith(loading: true));
    // Fetch individual results based on proximity and other criteria.
    householdList =
        await addressRepository.searchHouseHoldbyAddress(AddressSearchModel(
      latitude: event.latitude,
      longitude: event.longititude,
      maxRadius: event.maxRadius,
      offset: event.offset,
      limit: event.limit,
    ));
    // Extract individual IDs from proximity-based individual results.
    final householdClientReferenceIds =
        householdList.map((e) => e.clientReferenceId).toList();
    householdMembersList = await fetchHouseholdMembersBulk(
      null,
      householdClientReferenceIds,
    );
    final List<String> individualClientReferenceIds = householdMembersList
        .map((e) => e.individualClientReferenceId.toString())
        .toList();
    individualsList = await individual.search(
      IndividualSearchModel(clientReferenceId: individualClientReferenceIds),
    );
    projectBeneficiariesList = await fetchProjectBeneficiary(
      beneficiaryType != BeneficiaryType.individual
          ? householdClientReferenceIds
          : individualClientReferenceIds,
    );
    if (projectBeneficiariesList.isNotEmpty) {
      // Search for tasks and side effects based on project beneficiaries.
      taskList = await fetchTaskbyProjectBeneficiary(projectBeneficiariesList);
      sideEffectsList =
          await sideEffectDataRepository.search(SideEffectSearchModel(
        taskClientReferenceId:
            taskList.map((e) => e.clientReferenceId).toList(),
      ));
      referralsList = await referralDataRepository.search(ReferralSearchModel(
        projectBeneficiaryClientReferenceId:
            projectBeneficiariesList.map((e) => e.clientReferenceId).toList(),
      ));
    }
    // Initialize a list to store household member wrappers.
    final containers = <HouseholdMemberWrapper>[...state.householdMembers];
    // Group household members by household client reference ID.
    final groupedHouseholdsMembers = householdMembersList
        .groupListsBy((element) => element.householdClientReferenceId);
    // Iterate through grouped households and retrieve additional data.
    for (final entry in groupedHouseholdsMembers.entries) {
      HouseholdModel filteredHousehold;
      List<IndividualModel> filteredIndividuals;
      List<ProjectBeneficiaryModel> filteredBeneficiaries;
      List<TaskModel> filteredTasks;
      final householdId = entry.key;
      if (householdId == null) continue;
      filteredHousehold =
          householdList.firstWhere((e) => e.clientReferenceId == householdId);
      filteredIndividuals = individualsList
          .where((element) => entry.value
              .map((e) => e.individualClientReferenceId)
              .contains(element.clientReferenceId))
          .toList();
      filteredBeneficiaries = projectBeneficiariesList
          .where((element) => beneficiaryType == BeneficiaryType.individual
              ? entry.value
                  .map((e) => e.individualClientReferenceId)
                  .contains(element.beneficiaryClientReferenceId)
              : entry.key == element.beneficiaryClientReferenceId)
          .toList();

      final beneficiaryClientReferenceIds = filteredBeneficiaries
          .map((e) => e.beneficiaryClientReferenceId)
          .toList();

      final List<IndividualModel> beneficiaryIndividuals = filteredIndividuals
          .where((element) =>
              beneficiaryClientReferenceIds.contains(element.clientReferenceId))
          .toList();

      final projectBeneficiaryClientReferenceIds =
          filteredBeneficiaries.map((e) => e.clientReferenceId).toList();

      filteredTasks = taskList
          .where((element) => projectBeneficiaryClientReferenceIds
              .contains(element.projectBeneficiaryClientReferenceId))
          .toList();

      final List<ReferralModel> filteredReferrals = referralsList
          .where((element) => projectBeneficiaryClientReferenceIds
              .contains(element.projectBeneficiaryClientReferenceId))
          .toList();

      final taskClientReferenceIds =
          filteredTasks.map((e) => e.clientReferenceId).toList();

      final List<SideEffectModel> filteredSideEffects = sideEffectsList
          .where((element) =>
              taskClientReferenceIds.contains(element.taskClientReferenceId))
          .toList();

      // Find the head of household from the individuals.
      final head = filteredIndividuals.firstWhereOrNull(
        (element) =>
            element.clientReferenceId ==
            entry.value
                .firstWhereOrNull(
                  (element) => element.isHeadOfHousehold,
                )
                ?.individualClientReferenceId,
      );
      if (head == null) continue;
      // Create a container for household members and associated data.
      if (filteredBeneficiaries.isNotEmpty) {
        containers.add(
          HouseholdMemberWrapper(
            household: filteredHousehold,
            headOfHousehold: head,
            members: beneficiaryType == BeneficiaryType.individual
                ? beneficiaryIndividuals
                : filteredIndividuals,
            projectBeneficiaries: filteredBeneficiaries,
            tasks: filteredTasks.isEmpty ? null : filteredTasks,
            sideEffects:
                filteredSideEffects.isEmpty ? null : filteredSideEffects,
            referrals: filteredReferrals.isEmpty ? null : filteredReferrals,
          ),
        );
      }
    }
    // Update the state with the   results and mark the search as completed.
    emit(state.copyWith(
      householdMembers: containers,
      loading: false,
    ));
  }
}
