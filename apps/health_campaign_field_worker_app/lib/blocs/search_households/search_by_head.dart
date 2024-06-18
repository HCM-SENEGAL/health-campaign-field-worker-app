import 'dart:async';

import 'package:collection/collection.dart';

import '../../models/entities/address.dart';
import '../../models/entities/beneficiary_type.dart';
import '../../models/entities/household.dart';
import '../../models/entities/household_member.dart';
import '../../models/entities/individual.dart';
import '../../models/entities/name.dart';
import '../../models/entities/project_beneficiary.dart';
import '../../models/entities/referral.dart';
import '../../models/entities/side_effect.dart';
import '../../models/entities/task.dart';
import 'search_households.dart';

class SearchByHeadBloc extends SearchHouseholdsBloc {
  SearchByHeadBloc({
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
    on(
      _handleSearchByHouseholdHead,
      transformer: debounce<SearchHouseholdsSearchByHouseholdHeadEvent>(
        const Duration(milliseconds: 100),
      ),
    );
  }

  FutureOr<void> _handleSearchByHouseholdHead(
    SearchHouseholdsSearchByHouseholdHeadEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    // Check if the search text is empty; if so, clear the results and return.
    if (event.searchText.trim().isEmpty) {
      super.emit(state.copyWith(
        householdMembers: [],
        searchQuery: null,
        loading: false,
      ));

      return;
    }

    // Update the state to indicate that the search is in progress.
    super.emit(state.copyWith(
      loading: true,
      searchQuery: event.searchText,
    ));

    // Perform a series of asynchronous data retrieval operations based on the search criteria.

    // Fetch household results based on proximity and other criteria.

    List<IndividualModel> individuals = [];
    List<IndividualModel> proximityBasedIndividualResults = [];
    List<SideEffectModel> sideEffects = [];
    final containers = <HouseholdMemberWrapper>[];
    List<ReferralModel> referrals = [];
    List<TaskModel> tasks = [];

    if (event.isProximityEnabled) {
      // Fetch individual results based on proximity and other criteria.
      proximityBasedIndividualResults = await addressRepository
          .searchHouseHoldByIndividual(AddressSearchModel(
        latitude: event.latitude,
        longitude: event.longitude,
        maxRadius: event.maxRadius,
        limit: event.limit,
        offset: event.offset,
      ));
    }
    // Extract individual IDs from proximity-based individual results.
    final List<String> individualIds = proximityBasedIndividualResults
        .map((e) => e.clientReferenceId)
        .toList();

    individuals = await individual.search(
      event.isProximityEnabled
          ? IndividualSearchModel(
              clientReferenceId: individualIds,
              name: NameSearchModel(givenName: event.searchText.trim()),
            )
          : IndividualSearchModel(
              name: NameSearchModel(givenName: event.searchText.trim()),
              limit: event.limit,
              offset: event.offset,
            ),
    );

    final individualClientReferenceIds =
        individuals.map((e) => e.clientReferenceId).toList();
    // Search for individual results using the extracted IDs and search text.
    final List<HouseholdMemberModel> householdMembers =
        await fetchHouseholdMembersBulk(
      individualClientReferenceIds,
      null,
    );

    final househHoldIds =
        householdMembers.map((e) => e.householdClientReferenceId!).toList();
    final List<HouseholdMemberModel> allhouseholdMembers =
        await fetchHouseholdMembersBulk(
      null,
      househHoldIds,
    );

    final List<IndividualModel> individualMembers =
        await individual.search(IndividualSearchModel(
      clientReferenceId: allhouseholdMembers
          .map((e) => e.individualClientReferenceId.toString())
          .toList(),
    ));
    final List<HouseholdModel> houseHolds = await household.search(
      HouseholdSearchModel(
        clientReferenceId: househHoldIds,
      ),
    );

    final projectBeneficiaries = await fetchProjectBeneficiary(
      beneficiaryType != BeneficiaryType.individual
          ? househHoldIds
          : allhouseholdMembers
              .map((e) => e.individualClientReferenceId.toString())
              .toList(),
    );

    // Search for individual results based on the search text only.

    if (projectBeneficiaries.isNotEmpty) {
      // Search for tasks and side effects based on project beneficiaries.
      tasks = await fetchTaskbyProjectBeneficiary(projectBeneficiaries);

      sideEffects = await sideEffectDataRepository.search(SideEffectSearchModel(
        taskClientReferenceId: tasks.map((e) => e.clientReferenceId).toList(),
      ));

      referrals = await referralDataRepository.search(ReferralSearchModel(
        projectBeneficiaryClientReferenceId:
            projectBeneficiaries.map((e) => e.clientReferenceId).toList(),
      ));
    }

    // Initialize a list to store household members.
    final groupedHouseholds = allhouseholdMembers
        .groupListsBy((element) => element.householdClientReferenceId);

    // Iterate through grouped households and retrieve additional data.
    for (final entry in groupedHouseholds.entries) {
      final householdId = entry.key;

      if (householdId == null) continue;
      // Retrieve the first household result.
      final householdresult =
          houseHolds.firstWhere((e) => e.clientReferenceId == householdId);
      // Search for individuals based on proximity, beneficiary type, and search text.
      final List<String?> membersIds =
          entry.value.map((e) => e.individualClientReferenceId).toList();
      final List<IndividualModel> individualMembersList = individualMembers
          .where((element) => membersIds.contains(element.clientReferenceId))
          .toList();
      final List<ProjectBeneficiaryModel> beneficiaries = projectBeneficiaries
          .where((element) => beneficiaryType == BeneficiaryType.individual
              ? membersIds.contains(element.beneficiaryClientReferenceId)
              : (househHoldIds).contains(element.beneficiaryClientReferenceId))
          .toList();
      // Find the head of household from the individuals.
      final head = individualMembersList.firstWhereOrNull(
        (element) =>
            element.clientReferenceId ==
            entry.value
                .firstWhereOrNull(
                  (element) => element.isHeadOfHousehold,
                )
                ?.individualClientReferenceId,
      );

      if (head == null) continue;

      // Search for project beneficiaries based on client reference ID and project.

      if (beneficiaries.isNotEmpty) {
        // Create a container for household members and associated data.
        containers.add(
          HouseholdMemberWrapper(
            household: householdresult,
            headOfHousehold: head,
            members: individualMembersList,
            projectBeneficiaries: beneficiaries,
            tasks: tasks.isEmpty ? null : tasks,
            sideEffects: sideEffects.isEmpty ? null : sideEffects,
            referrals: referrals.isEmpty ? null : referrals,
          ),
        );
      }

      // Update the state with the results and mark the search as completed.
    }
    super.emit(state.copyWith(
      searchQuery: event.searchText,
      householdMembers: containers,
      loading: false,
    ));
  }
}
