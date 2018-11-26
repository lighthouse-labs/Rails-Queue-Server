window.Queue || (window.Queue = {});

window.Queue.Locations = class Locations extends React.Component {
  propTypes: {
    locations: PropTypes.array.isRequired,
    selectedLocation: PropTypes.object,
    myLocation: PropTypes.object,
  }

  constructor(props) {
    super(props);
    // this.state = {
    //   selectedLocation: this.props.selectedLocation || this.props.myLocation || this.props.locations[0]
    // }
  }

  renderLocation = (location) => {
    const selectedLocation = this.props.selectedLocation;
    if (selectedLocation && selectedLocation.id === location.id) {
      return(
        <Queue.Location key={`location-${location.id}`} location={location} />
      )
    }
  }

  renderLocations() {
    const locations = this.props.locations;
    return locations.map(this.renderLocation);
  }

  render() {
    const locations = this.props.locations;

    return (
      <div className="locations">
        {this.renderLocations(locations)}
      </div>
    );
  }
}
