window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.QueueMenu = ({user, userQueue, setUserQueue, toggleDuty, connected}) => {

  const queueName = () => {
    let name = ' queue';
    if (userQueue === 'admin') {
      name = 'the admin' + name;
    } else if (userQueue) {
      if (userQueue.firstName.slice(-1) === 's') {
        name = `${userQueue.firstName}'` + name;
      } else {
        name = `${userQueue.firstName}'s` + name;
      }
    } else {
      name = 'the' + name;
    }
    return name;
  }

  const toggleAdminQueue = () => {
    setUserQueue(userQueue ? null : 'admin');
  }

  const dutyClass = () => {
    const checkUser = userQueue || user;
    return checkUser && checkUser.onDuty ? 'btn-danger' : 'btn-success'
  }

  const dutyText = () => {
    let buttonUser = userQueue || user;
    if (buttonUser === 'admin') {
      return ''
    } else {
      return `Go ${buttonUser.onDuty ? 'off' : 'on'} duty${userQueue ? ` for ${userQueue.firstName}` : ''}`;
    }
  }

  return(
    <div className="queue-header">
      <h2 className="queue-title" >{queueName()} {connected || <i className="fas fa-spinner text-primary queue-loader"></i>}</h2>
      
      <div className="actions">
        {user.admin &&
          <label className="switch mr-3">
            <input type="checkbox" onClick={toggleAdminQueue}/>
            <span 
              className="slider round"
              data-toggle='tooltip' 
              data-placement='bottom' 
              title={`Toggle Admin Queue`}
              data-original-title={`Toggle Admin Queue`}
              ref={(ref) => $(ref).tooltip()}
            ></span>
          </label>
        }

        <button
          className={"btn " + dutyClass()}
          onClick={toggleDuty} 
          disabled={userQueue === 'admin'}
          href="#" 
          data-toggle='tooltip' 
          data-placement='bottom' 
          title={dutyText()}
          data-original-title={dutyText()}
          ref={(ref) => $(ref).tooltip()}
        >
          <i className="fa fa-fw fa-bullhorn"></i>
          <span className="only-on-small">Go off duty</span>
        </button>
      </div>
    </div>
  )
}
