import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/workspace.dart';
import 'package:needoff/utils/dates.dart';

Future<QueryResult> create(Workspace ws) async {
  String membersStr = '[${ws.members.map((m) => '"$m"').toList().join(',')}]';
  QueryResult res = await gql.rawMutation('''
mutation CreateWS {
  createWorkspace(name: "${ws.name}", description: "${ws.description}", members: $membersStr) {
    ok,
    ws {
      id,
      name,
      description
    }
  }
}
  ''');

  return res;
}

Future<QueryResult> update(int wsId, String name, String description) async {
  QueryResult res = await gql.rawMutation('''
mutation UpdateWS {
  updateWorkspace(wsId: $wsId, name: "$name", description: "$description") {
    ok,
  }
}
  ''');

  return res;
}

Future<QueryResult> setPolicy(
    int wsId, int maxPaidVacs, int maxUnpaidVacs, int maxSickDays) async {
  QueryResult res = await gql.rawMutation('''
mutation SetRules(\$validationRule: String, \$balancesRule: String) {
  validation: setWorkspaceRule(
    wsId: $wsId,
    type: "DAY_OFF_VALIDATION",
    rule: \$validationRule,
    ) { ok },
  balance: setWorkspaceRule(
    wsId: 1,
    type: "BALANCE_CALCULATION",
    rule: \$balancesRule
    ) { ok }
}
  ''', variables: {
    'validationRule': _validationRule,
    'balancesRule': _makeRule(
        maxPaid: maxPaidVacs / 12, maxUnpaid: maxUnpaidVacs / 12, maxSick: maxSickDays /  12),
  });

  return res;
}

Future<QueryResult> fetch() async {
  QueryResult res = await gql.rawQuery('''
query MyWorkspaces {
  workspaces: myWorkspaces {
    id,
    name,
    description,
  }
}
  ''');
  return res;
}

Future<QueryResult> fetchWorkspace(int id) async {
  QueryResult res = await gql.rawQuery('''
query LoadWorkspace {
  owner: workspaceOwner(workspaceId: $id) {
    firstName,
    lastName,
    email,
    userId,
  }
  info: workspaceById(workspaceId: $id) {
    id,
    name,
    description,
  }
  invitations: workspaceInvitations(workspaceId: $id) {
    id,
    email,
    status
  }
  members: workspaceMembers(workspaceId: $id) {
    userId,
    startDate,
    profile {
      firstName,
      lastName,
      email,
    }
  }
  dates: workspaceDates(workspaceId: $id) {
    id,
    name,
    date,
    isOfficialHoliday
  }
}
  ''');

  return res;
}

Future<QueryResult> fetchOwner(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query GetOwner {
  owner: workspaceOwner(workspaceId: $workspaceId) {
    firstName,
    lastName,
    email,
    userId,
  }
}  
  ''');

  return res;
}

Future<QueryResult> addMember(
    String email, DateTime startDate, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation AddMember {
  addWorkspaceMember(email: "$email", startDate: "${formatForGQL(startDate)}", wsId: $workspaceId){
    ok
  }
}
  ''');

  return res;
}

Future<QueryResult> updateMember(int memberId, int workspaceId, DateTime startDate) async {
  QueryResult res = await gql.rawMutation('''
mutation updateMember {
  updateWorkspaceMember(userId: $memberId, wsId: $workspaceId, startDate: "${formatForGQL(startDate)}"){
    ok
  }
}
  ''');

  return res;
}
Future<QueryResult> removeMember(String email, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveMember {
  removeWorkspaceMember(email: "$email", wsId: $workspaceId){
    ok
  }
}
  ''');

  return res;
}

Future<QueryResult> fetchWorkspaceDates(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query LoadWorkspaceDates {
  dates: workspaceDates(workspaceId: $workspaceId) {
    id,
    name,
    date,
    isOfficialHoliday
  }
}
  ''');

  return res;
}

Future<QueryResult> removeWorkspaceDate(int workspaceDateId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveWorkspaceDate {
  removeWorkspaceDate(id: $workspaceDateId) {
    ok
  }
}
  ''');

  return res;
}

Future<QueryResult> addWorkspaceDate(
    int workspaceId, DateTime date, String name, bool isOfficialHoliday) async {
  QueryResult res = await gql.rawMutation('''
mutation AddWorkspaceDate {
  addWorkspaceDate(wsId: $workspaceId, date: "${formatForGQL(date)}", name: "$name", isOfficialHoliday: $isOfficialHoliday) {
    ok
  }
}
  ''');

  return res;
}

_makeRule({double maxPaid = 18, double maxUnpaid = 30, double maxSick = 10}) {
  return '''
from application.rules.models import BalanceCalculationRulePayload, LeaveDay
from application.balances.models import LeaveTypes
import datetime

used_paid_leaves = 0
used_unpaid_leaves = 0
used_sick_leaves = 0


rule calculate_paid_leaves:
    when:
        \$leave_day := LeaveDay(leave.leave_type == LeaveTypes.VACATION_PAID and is_official_holiday != True and date.weekday() < 5 and leave.approved_by_id != None)
    then:
        attribute used_paid_leaves = used_paid_leaves + 1


rule calculate_unpaid_leaves:
    when:
        \$leave_day := LeaveDay(leave.leave_type == LeaveTypes.VACATION_UNPAID and is_official_holiday != True and date.weekday() < 5 and leave.approved_by_id != None)
    then:
        attribute used_unpaid_leaves = used_unpaid_leaves + 1


rule calculate_sick_leaves:
    when:
        \$leave_day := LeaveDay(leave.leave_type == LeaveTypes.SICK_LEAVE and is_official_holiday != True and date.weekday() < 5 and leave.approved_by_id != None)
    then:
        attribute used_sick_leaves = used_sick_leaves + 1


rule calculate_totals:
    when:
        \$payload := BalanceCalculationRulePayload()
    then:
        attribute now = datetime.datetime.now()
        attribute worked_months = (now.year - \$payload.start_date.year) * 12 + now.month - \$payload.start_date.month

        modify \$payload:
            total_paid_leaves = $maxPaid * min(worked_months, 20) 
            total_unpaid_leaves = $maxUnpaid * min(worked_months, 12)
            total_sick_leaves = $maxSick * min(worked_months, 12)
            left_paid_leaves = \$payload.total_paid_leaves - used_paid_leaves
            left_unpaid_leaves = \$payload.total_unpaid_leaves - used_unpaid_leaves
            left_sick_leaves = \$payload.total_sick_leaves - used_sick_leaves
''';
}

String _validationRule = '''
from application.rules.models import DayOffValidationPayload, LeaveDay
from application.balances.models import LeaveTypes
from application.workspace.models import WorkspaceUserRoles
import datetime

business_days_count = 0

rule calculate_business_days:
    when:
        \$leave_day := LeaveDay(is_official_holiday != True and date.weekday() < 5)
    then:
        attribute business_days_count = business_days_count + 1

rule day_off_start_date_is_after_start_date_in_ws:
    when:
        \$payload := DayOffValidationPayload( leave.start_date <= user_start_date )
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Your leave must start at you joined a workspace")

rule paid_leave_is_after_probation:
    when:
        \$payload := DayOffValidationPayload( ((leave.start_date.year - user_start_date.year) * 12 + leave.start_date.month - user_start_date.month) <= 3 and leave.leave_type == LeaveTypes.VACATION_PAID)
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Your paid leave must start at least after 3 months of probation period")

rule leave_start_date_must_be_2_weeks_from_now:
    when:
        \$payload := DayOffValidationPayload( (leave.start_date - datetime.date.today()).days < 14 and leave.leave_type != LeaveTypes.SICK_LEAVE)
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Leave must start at least 2 weeks from now")

rule doctors_note_needed_for_3_sick_leaves:
    when:
        \$payload := DayOffValidationPayload(leave.leave_type == LeaveTypes.SICK_LEAVE)
    then:
        \$payload.warnings.append("Our policies require a doctor’s note if for sick leaves longer than 3 days")

rule leaves_longer_than_10_business_days:
    when:
        \$payload := DayOffValidationPayload(business_days_count > 10)
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Planned leave cannot exceed 10 business days in a row")

rule day_off_start_date_is_after_start_date_in_ws:
    when:
        \$payload := DayOffValidationPayload( leave.start_date > leave.end_date )
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Start date cannot be after the end date")

rule paid_leaves_precedent_over_unpaid:
    when:
        \$payload := DayOffValidationPayload( leave.leave_type == LeaveTypes.VACATION_UNPAID and balance.left_paid_leaves > 0 )
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Unpaid leaves cannot be requested when paid leaves are available")

rule negative_balance_vacation_paid:
    when:
        \$payload := DayOffValidationPayload( leave.leave_type == LeaveTypes.VACATION_PAID and business_days_count > balance.left_paid_leaves )
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Paid vacations balance exceeded")

rule negative_balance_vacation_unpaid:
    when:
        \$payload := DayOffValidationPayload( leave.leave_type == LeaveTypes.VACATION_UNPAID and business_days_count > balance.left_unpaid_leaves )
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Unpaid vacations balance exceeded")

rule negative_balance_vacation_unpaid:
    when:
        \$payload := DayOffValidationPayload( leave.leave_type == LeaveTypes.SICK_LEAVE and business_days_count > balance.left_sick_leaves )
    then:
        modify \$payload:
            is_rejected = True
        \$payload.errors.append("Sick leaves balance exceeded")


rule auto_approve_workspace_owner_leave:
    when:
        \$payload := DayOffValidationPayload( WorkspaceUserRoles.OWNER in user_roles )

    then:
        \$payload.leave.approved_by_id = \$payload.leave.user_id
        \$payload.notes.append("Automatically approved based on role")
''';
