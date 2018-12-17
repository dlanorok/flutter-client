import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/ui/project/project_screen.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/redux/project/project_actions.dart';
import 'package:invoiceninja_flutter/data/models/project_model.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/ui/project/view/project_view.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';

class ProjectViewScreen extends StatelessWidget {
  const ProjectViewScreen({Key key}) : super(key: key);
  static const String route = '/project/view';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ProjectViewVM>(
      converter: (Store<AppState> store) {
        return ProjectViewVM.fromStore(store);
      },
      builder: (context, vm) {
        return ProjectView(
          viewModel: vm,
        );
      },
    );
  }
}

class ProjectViewVM {

  ProjectViewVM({
    @required this.project,
    @required this.client,
    @required this.company,
    @required this.onActionSelected,
    @required this.onEditPressed,
    @required this.onBackPressed,
    @required this.onRefreshed,
    @required this.isSaving,
    @required this.isLoading,
    @required this.isDirty,
  });

  factory ProjectViewVM.fromStore(Store<AppState> store) {
    final state = store.state;
    final project = state.projectState.map[state.projectUIState.selectedId];

    Future<Null> _handleRefresh(BuildContext context) {
      final completer = snackBarCompleter(
          context, AppLocalization.of(context).refreshComplete);
      store.dispatch(LoadProject(completer: completer, projectId: project.id));
      return completer.future;
    }

    return ProjectViewVM(
        company: state.selectedCompany,
        isSaving: state.isSaving,
        isLoading: state.isLoading,
        isDirty: project.isNew,
        project: project,
        client: state.clientState.map[project.clientId],
        onEditPressed: (BuildContext context) {
          store.dispatch(EditProject(project: project, context: context));
        },
        onRefreshed: (context) => _handleRefresh(context),
        onBackPressed: () =>
            store.dispatch(UpdateCurrentRoute(ProjectScreen.route)),
        onActionSelected: (BuildContext context, EntityAction action) {
          final localization = AppLocalization.of(context);
          switch (action) {
            case EntityAction.archive:
              store.dispatch(ArchiveProjectRequest(
                  popCompleter(context, localization.archivedProject),
                  project.id));
              break;
            case EntityAction.delete:
              store.dispatch(DeleteProjectRequest(
                  popCompleter(context, localization.deletedProject),
                  project.id));
              break;
            case EntityAction.restore:
              store.dispatch(RestoreProjectRequest(
                  snackBarCompleter(context, localization.restoredProject),
                  project.id));
              break;
          }
        });
  }

  final ProjectEntity project;
  final ClientEntity client;
  final CompanyEntity company;
  final Function(BuildContext, EntityAction) onActionSelected;
  final Function(BuildContext) onEditPressed;
  final Function onBackPressed;
  final Function(BuildContext) onRefreshed;
  final bool isSaving;
  final bool isLoading;
  final bool isDirty;
}
