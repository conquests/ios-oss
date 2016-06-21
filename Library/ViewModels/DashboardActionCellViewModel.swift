import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardActionCellViewModelInputs {
  /// Call when the activity button is tapped.
  func activityTapped()

  /// Call to configure cell with project value.
  func configureWith(project project: Project)

  /// Call when the messages button is tapped.
  func messagesTapped()

  /// Call when the post update button is tapped.
  func postUpdateTapped()

  /// Call when the share button is tapped.
  func shareTapped()
}

public protocol DashboardActionCellViewModelOutputs {
  /// Emits with the project when should go to activity screen.
  var goToActivity: Signal<Project, NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<Project, NoError> { get }

  /// Emits with the project when should go to post update screen.
  var goToPostUpdate: Signal<Project, NoError> { get }

  /// Emits the last update published time to display.
  var lastUpdatePublishedAt: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the last update published label should be hidden.
  var lastUpdatePublishedLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the messages row should be hidden.
  var messagesRowHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the post update button should be hidden
  var postUpdateButtonHidden: Signal<Bool, NoError> { get }

  /// Emits with the project when share sheet should be shown.
  var showShareSheet: Signal<Project, NoError> { get }

  /// Emits the count of unread messages to be displayed.
  var unreadMessagesCount: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the unread messages indicator should be hidden.
  var unreadMessagesCountHidden: Signal<Bool, NoError> { get }

  /// Emits the count of unseen activities to be displayed.
  var unseenActivitiesCount: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the unseen activities indicator should be hidden.
  var unseenActivitiesCountHidden: Signal<Bool, NoError> { get }
}

public protocol DashboardActionCellViewModelType {
  var inputs: DashboardActionCellViewModelInputs { get }
  var outputs: DashboardActionCellViewModelOutputs { get }
}

public final class DashboardActionCellViewModel: DashboardActionCellViewModelInputs,
  DashboardActionCellViewModelOutputs, DashboardActionCellViewModelType {

  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.goToActivity = project.takeWhen(self.activityTappedProperty.signal)

    self.goToMessages = project.takeWhen(self.messagesTappedProperty.signal)

    self.goToPostUpdate = project.takeWhen(self.postUpdateTappedProperty.signal)

    self.showShareSheet = project.takeWhen(self.shareTappedProperty.signal)

    self.lastUpdatePublishedAt = project
      .map {
        if let lastUpdatePublishedAt = $0.creatorData.lastUpdatePublishedAt {
          return Strings.dashboard_post_update_button_subtitle_last_updated_on_date(
            date: Format.date(secondsInUTC: lastUpdatePublishedAt, timeStyle: .NoStyle)
          )
        }
        return Strings.dashboard_post_update_button_subtitle_you_have_not_posted_an_update_yet()
    }

    self.unreadMessagesCount = project.map { Format.wholeNumber($0.creatorData.unreadMessagesCount ?? 0) }
    self.unreadMessagesCountHidden = project.map { ($0.creatorData.unreadMessagesCount ?? 0) == 0 }
    self.unseenActivitiesCount = project.map { Format.wholeNumber($0.creatorData.unseenActivityCount ?? 0) }
    self.unseenActivitiesCountHidden = project.map { ($0.creatorData.unseenActivityCount ?? 0) == 0 }

    self.lastUpdatePublishedLabelHidden = project.map { !$0.creatorData.permissions.contains(.post) }
    self.postUpdateButtonHidden = self.lastUpdatePublishedLabelHidden

    self.messagesRowHidden = project.map { $0.creator != AppEnvironment.current.currentUser }
  }

  private let activityTappedProperty = MutableProperty()
  public func activityTapped() {
    activityTappedProperty.value = ()
  }

  private let messagesTappedProperty = MutableProperty()
  public func messagesTapped() {
    messagesTappedProperty.value = ()
  }

  private let postUpdateTappedProperty = MutableProperty()
  public func postUpdateTapped() {
    postUpdateTappedProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let shareTappedProperty = MutableProperty()
  public func shareTapped() {
    shareTappedProperty.value = ()
  }

  public let goToActivity: Signal<Project, NoError>
  public let goToMessages: Signal<Project, NoError>
  public let goToPostUpdate: Signal<Project, NoError>
  public let lastUpdatePublishedAt: Signal<String, NoError>
  public let lastUpdatePublishedLabelHidden: Signal<Bool, NoError>
  public let messagesRowHidden: Signal<Bool, NoError>
  public let postUpdateButtonHidden: Signal<Bool, NoError>
  public let showShareSheet: Signal<Project, NoError>
  public let unreadMessagesCount: Signal<String, NoError>
  public let unreadMessagesCountHidden: Signal<Bool, NoError>
  public let unseenActivitiesCount: Signal<String, NoError>
  public let unseenActivitiesCountHidden: Signal<Bool, NoError>

  public var inputs: DashboardActionCellViewModelInputs { return self }
  public var outputs: DashboardActionCellViewModelOutputs { return self }
}