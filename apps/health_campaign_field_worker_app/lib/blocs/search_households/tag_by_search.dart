import 'dart:async';

import '../../models/data_model.dart';
import 'search_households.dart';

class TagSearchBloc extends SearchHouseholdsBloc {
  TagSearchBloc({
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
    on(handleSearchByTag);
  }

  FutureOr<void> handleSearchByTag(
    SearchHouseholdsByTagEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    List<ProjectBeneficiaryModel> beneficiaries =
        await projectBeneficiary.search(
      ProjectBeneficiarySearchModel(
        tag: event.tag,
        projectId: event.projectId,
      ),
    );

    /* [TODO: Need to handle the Tag search based on Beneficary Type
   current implementation is based on the individual based project
   ] */
    List<IndividualModel> individuals = [];
    List<HouseholdModel> households = [];

    if (beneficiaryType == BeneficiaryType.household) {
      households = await household.search(HouseholdSearchModel(
        clientReferenceId:
            beneficiaries.map((e) => e.beneficiaryClientReferenceId!).toList(),
      ));
    } else {
      individuals = await individual.search(
        IndividualSearchModel(
          clientReferenceId: beneficiaries
              .map((e) => e.beneficiaryClientReferenceId!)
              .toList(),
        ),
      );
    }

    // Initialize a list to store household member wrappers.
    final containers = <HouseholdMemberWrapper>[];
    if (individuals.isNotEmpty || households.isNotEmpty) {
      final hhMembers = beneficiaryType == BeneficiaryType.individual
          ? await householdMember.search(
              HouseholdMemberSearchModel(
                individualClientReferenceIds:
                    individuals.map((e) => e.clientReferenceId).toList(),
              ),
            )
          : await householdMember.search(
              HouseholdMemberSearchModel(
                householdClientReferenceIds:
                    households.map((e) => e.clientReferenceId).toList(),
              ),
            );

      final member = hhMembers.first;

      final members = await householdMember.search(
        HouseholdMemberSearchModel(
          householdClientReferenceId: member.householdClientReferenceId,
        ),
      );
      final headMember =
          members.where((element) => element.isHeadOfHousehold).first;

      final individualList = await individual.search(
        IndividualSearchModel(
          clientReferenceId:
              members.map((e) => e.individualClientReferenceId!).toList(),
        ),
      );

      final householdList = await household.search(HouseholdSearchModel(
        clientReferenceId: [members.first.householdClientReferenceId!],
      ));

      final projectBeneficiaries = await fetchProjectBeneficiary(
        beneficiaryType != BeneficiaryType.individual
            ? [householdList.first.clientReferenceId]
            : individualList
                .map((e) => e.clientReferenceId.toString())
                .toList(),
      );
      final beneficiaryClientReferenceIds = projectBeneficiaries
          .map((e) => e.beneficiaryClientReferenceId)
          .toList();

      final List<IndividualModel> beneficiaryIndividuals = individualList
          .where((element) =>
              beneficiaryClientReferenceIds.contains(element.clientReferenceId))
          .toList();

      // Search for tasks and side effects based on project beneficiaries.
      final tasks = await fetchTaskbyProjectBeneficiary(projectBeneficiaries);

      final referrals = await referralDataRepository.search(ReferralSearchModel(
        projectBeneficiaryClientReferenceId:
            projectBeneficiaries.map((e) => e.clientReferenceId).toList(),
      ));
      final sideEffects =
          await sideEffectDataRepository.search(SideEffectSearchModel(
        taskClientReferenceId: tasks.map((e) => e.clientReferenceId).toList(),
      ));

      // Group household members by household client reference ID.

      containers.add(
        HouseholdMemberWrapper(
          household: householdList.firstWhere((element) =>
              element.clientReferenceId == member.householdClientReferenceId),
          headOfHousehold: individualList.firstWhere((element) =>
              headMember.individualClientReferenceId ==
              element.clientReferenceId),
          members: beneficiaryType == BeneficiaryType.individual
              ? beneficiaryIndividuals
              : individualList,
          projectBeneficiaries: projectBeneficiaries,
          tasks: tasks.isEmpty ? null : tasks,
          sideEffects: sideEffects.isEmpty ? null : sideEffects,
          referrals: referrals.isEmpty ? null : referrals,
        ),
      );
    }

    emit(state.copyWith(
      householdMembers: containers,
      loading: false,
      tag: event.tag,
    ));
  }
}
