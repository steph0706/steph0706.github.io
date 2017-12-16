import React, { Component } from 'react';
import { VerticalTimeline, VerticalTimelineElement }  from 'react-vertical-timeline-component';
import 'react-vertical-timeline-component/style.min.css';

class TimelineComponent extends Component {

	render() {
		return (
			<div>
				<h1>{this.props.language}</h1>
				<p>{this.props.description}</p>

				<VerticalTimeline>
				  <VerticalTimelineElement
				    date={this.props.events[0].date}
				    iconStyle={{ background: 'rgb(33, 150, 243)', color: '#fff' }}>
				    <h3>{this.props.events[0].text}</h3>
				  </VerticalTimelineElement>
				  <VerticalTimelineElement
				    date={this.props.events[1].date}
				    iconStyle={{ background: 'rgb(33, 150, 243)', color: '#fff' }}>
				    <h3>{this.props.events[1].text}</h3>
				  </VerticalTimelineElement>
				</VerticalTimeline>
			</div>
		);
	}
}

export default TimelineComponent;