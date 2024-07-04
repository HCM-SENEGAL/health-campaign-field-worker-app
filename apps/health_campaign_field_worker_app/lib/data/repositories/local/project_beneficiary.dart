import 'dart:async';

import 'package:drift/drift.dart';

import '../../../models/data_model.dart';
import '../../../utils/utils.dart';
import '../../data_repository.dart';

class ProjectBeneficiaryLocalRepository extends LocalRepository<
    ProjectBeneficiaryModel, ProjectBeneficiarySearchModel> {
  ProjectBeneficiaryLocalRepository(super.sql, super.opLogManager);

  void listenToChanges({
    required ProjectBeneficiarySearchModel query,
    required void Function(List<ProjectBeneficiaryModel> data) listener,
    required String userId,
  }) {
    final select = sql.select(sql.projectBeneficiary)
      ..where(
        (tbl) => buildOr([
          if (query.projectId != null) tbl.projectId.equals(query.projectId!),
          if (query.beneficiaryRegistrationDateGte != null)
            tbl.dateOfRegistration.isBiggerOrEqualValue(
              query.beneficiaryRegistrationDateGte!.millisecondsSinceEpoch,
            ),
          if (query.beneficiaryRegistrationDateLte != null)
            tbl.dateOfRegistration.isSmallerOrEqualValue(
              query.beneficiaryRegistrationDateLte!.millisecondsSinceEpoch,
            ),
        ]),
      );

    select.watch().listen((event) {
      final data = event.map((e) {
        return ProjectBeneficiaryModel(
          clientReferenceId: e.clientReferenceId,
          dateOfRegistration: e.dateOfRegistration,
          projectId: e.projectId,
          tenantId: e.tenantId,
          beneficiaryClientReferenceId: e.beneficiaryClientReferenceId,
          id: e.id,
          tag: e.tag,
          rowVersion: e.rowVersion,
          isDeleted: e.isDeleted,
          beneficiaryId: e.beneficiaryId,
        );
      }).toList();

      listener(data);
    });
  }

  @override
  FutureOr<void> bulkCreate(
    List<ProjectBeneficiaryModel> entities,
  ) async {
    final projectBeneficiaryCompanions =
        entities.map((e) => e.companion).toList();

    await sql.batch((batch) async {
      batch.insertAll(
        sql.projectBeneficiary,
        projectBeneficiaryCompanions,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  @override
  FutureOr<List<ProjectBeneficiaryModel>> search(
    ProjectBeneficiarySearchModel query, [
    String? userId,
  ]) async {
    final selectQuery = sql.select(sql.projectBeneficiary).join([]);
    final results = await (selectQuery
          ..where(
            buildAnd(
              [
                if (query.tag != null)
                  sql.projectBeneficiary.tag.equals(
                    query.tag!,
                  ),
                if (query.clientReferenceId != null)
                  sql.projectBeneficiary.clientReferenceId.isIn(
                    query.clientReferenceId!,
                  ),
                if (query.beneficiaryClientReferenceId != null)
                  sql.projectBeneficiary.beneficiaryClientReferenceId
                      .isIn(query.beneficiaryClientReferenceId!),
                if (query.id != null)
                  sql.projectBeneficiary.id.equals(
                    query.id!,
                  ),
                if (query.projectId != null)
                  sql.projectBeneficiary.projectId.equals(
                    query.projectId!,
                  ),
                if (query.beneficiaryId != null)
                  sql.projectBeneficiary.beneficiaryId.equals(
                    query.beneficiaryId!,
                  ),
                if (query.dateOfRegistrationTime != null)
                  sql.projectBeneficiary.dateOfRegistration.equals(
                    query.dateOfRegistration!,
                  ),
                if (query.beneficiaryRegistrationDateGte != null)
                  sql.projectBeneficiary.dateOfRegistration
                      .isBiggerOrEqualValue(
                    query
                        .beneficiaryRegistrationDateGte!.millisecondsSinceEpoch,
                  ),
                if (query.beneficiaryRegistrationDateLte != null)
                  sql.projectBeneficiary.dateOfRegistration
                      .isSmallerOrEqualValue(
                    query
                        .beneficiaryRegistrationDateLte!.millisecondsSinceEpoch,
                  ),
                if (userId != null)
                  sql.projectBeneficiary.clientCreatedBy.equals(
                    userId,
                  ),
              ],
            ),
          ))
        .get();

    return results
        .map((e) {
          final projectBeneficiary = e.readTable(sql.projectBeneficiary);

          return ProjectBeneficiaryModel(
            clientReferenceId: projectBeneficiary.clientReferenceId,
            tenantId: projectBeneficiary.tenantId,
            rowVersion: projectBeneficiary.rowVersion,
            id: projectBeneficiary.id,
            isDeleted: projectBeneficiary.isDeleted,
            beneficiaryClientReferenceId:
                projectBeneficiary.beneficiaryClientReferenceId,
            beneficiaryId: projectBeneficiary.beneficiaryId,
            dateOfRegistration: projectBeneficiary.dateOfRegistration,
            projectId: projectBeneficiary.projectId,
            tag: projectBeneficiary.tag,
            auditDetails: AuditDetails(
              createdTime: projectBeneficiary.auditCreatedTime!,
              createdBy: projectBeneficiary.auditCreatedBy!,
              lastModifiedBy: projectBeneficiary.auditModifiedBy,
              lastModifiedTime: projectBeneficiary.auditModifiedTime,
            ),
            clientAuditDetails: (projectBeneficiary.clientCreatedBy != null &&
                    projectBeneficiary.clientCreatedTime != null)
                ? ClientAuditDetails(
                    createdBy: projectBeneficiary.clientCreatedBy!,
                    createdTime: projectBeneficiary.clientCreatedTime!,
                    lastModifiedBy: projectBeneficiary.clientModifiedBy,
                    lastModifiedTime: projectBeneficiary.clientModifiedTime,
                  )
                : null,
          );
        })
        .where((element) => element.isDeleted != true)
        .toList();
  }

  @override
  FutureOr<void> create(
    ProjectBeneficiaryModel entity, {
    bool createOpLog = true,
    DataOperation dataOperation = DataOperation.create,
  }) async {
    final projectBeneficiaryCompanion = entity.companion;
    await sql.batch((batch) {
      batch.insert(sql.projectBeneficiary, projectBeneficiaryCompanion);
    });

    await super.create(entity);
  }

  @override
  FutureOr<void> update(
    ProjectBeneficiaryModel entity, {
    bool createOpLog = true,
  }) async {
    final projectBeneficiaryCompanion = entity.companion;

    await sql.batch((batch) {
      batch.update(
        sql.projectBeneficiary,
        projectBeneficiaryCompanion,
        where: (table) => table.clientReferenceId.equals(
          entity.clientReferenceId,
        ),
      );
    });

    return super.update(entity, createOpLog: createOpLog);
  }

  @override
  FutureOr<void> delete(
    ProjectBeneficiaryModel entity, {
    bool createOpLog = true,
  }) async {
    final updated = entity.copyWith(
      isDeleted: true,
      rowVersion: entity.rowVersion,
      clientAuditDetails: (entity.clientAuditDetails?.createdBy != null &&
              entity.clientAuditDetails!.createdTime != null)
          ? ClientAuditDetails(
              createdBy: entity.clientAuditDetails!.createdBy,
              createdTime: entity.clientAuditDetails!.createdTime,
              lastModifiedBy: entity.clientAuditDetails!.lastModifiedBy,
              lastModifiedTime: DateTime.now().millisecondsSinceEpoch,
            )
          : null,
    );
    await sql.batch((batch) {
      batch.update(
        sql.projectBeneficiary,
        updated.companion,
        where: (table) => table.clientReferenceId.equals(
          entity.clientReferenceId,
        ),
      );
    });

    return super.delete(updated);
  }

  @override
  DataModelType get type => DataModelType.projectBeneficiary;
}
