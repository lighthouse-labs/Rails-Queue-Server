window.Queue || (window.Queue = {});

window.Queue.Assistance = class Assistance extends React.Component {
  propTypes: {
    assistance: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  handleCancelAssisting = () => {
    this.setState({disabled: true});
    App.queue.cancelAssisting(this.props.assistance);
    ga('send', 'event', 'cancel-assistance', 'click');
  }

  handleEndAssisting = () => {
    this.openModal();
  }

  openModal() {
    this.refs.requestModal.open();
  }

  actionButtons() {
    const assistance = this.props.assistance;
    const buttons = [null];
    if (window.current_user.id === assistance.assistor.id) {
      buttons.push(<button key="cancel" className="btn btn-sm btn-light btn-hover-danger" onClick={this.handleCancelAssisting} disabled={this.state.disabled}>Cancel</button>);
      buttons.push(<button key="finish" className="btn btn-sm btn-secondary btn-main"onClick={this.handleEndAssisting} disabled={this.state.disabled}>Finish</button>);
    }
    return buttons;
  }

  renderActions() {
    return(
      <div className="actions pull-right">
        { App.ReactUtils.joinElements(this.actionButtons(), null) }
      </div>
    );
  }


  render() {
    const assistance = this.props.assistance;
    const request = assistance.assistanceRequest;
    const student = assistance.assistee;
    const assistor = assistance.assistor;

    return (
      <Queue.QueueItem type='Assistance' disabled={this.state.disabled}>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={request.startAt} />

        <Queue.TeacherInfo teacher={assistor} when={assistance.startAt} />

        <div className="blurb">
          {App.ReactUtils.renderActivityDetails(request.activity)}
          {App.ReactUtils.renderQuote(assistance.assistanceRequest.reason)}
        </div>
        {this.renderActions()}

        <Queue.RequestModal assistance={assistance} ref="requestModal" />
      </Queue.QueueItem>
    )
  }
}
