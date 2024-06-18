// Generated using mason. Do not modify by hand

import 'package:drift/drift.dart';

@TableIndex(name: 'givennameclientref', columns: {#givenName})
@TableIndex(name: 'familynameclientref', columns: {#familyName})
class Name extends Table {
  TextColumn get id => text().nullable()();
  TextColumn get individualClientReferenceId => text().nullable()();
  TextColumn get givenName => text().nullable()();
  TextColumn get familyName => text().nullable()();
  TextColumn get otherNames => text().nullable()();
  TextColumn get auditCreatedBy => text().nullable()();
  BoolColumn get nonRecoverableError =>
      boolean().nullable().withDefault(const Constant(false))();
  IntColumn get auditCreatedTime => integer().nullable()();
  IntColumn get clientCreatedTime => integer().nullable()();
  TextColumn get clientModifiedBy => text().nullable()();
  TextColumn get clientCreatedBy => text().nullable()();
  IntColumn get clientModifiedTime => integer().nullable()();
  TextColumn get auditModifiedBy => text().nullable()();
  IntColumn get auditModifiedTime => integer().nullable()();
  TextColumn get tenantId => text().nullable()();
  BoolColumn get isDeleted =>
      boolean().nullable().withDefault(const Constant(false))();
  IntColumn get rowVersion => integer().nullable()();

  TextColumn get additionalFields => text().nullable()();

  @override
  Set<Column> get primaryKey => {
        individualClientReferenceId,
        auditCreatedBy,
      };
}
