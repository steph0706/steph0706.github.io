import React, { Component} from 'react';
import {
  Hint,
  Sankey
} from 'react-vis';
import './App.css';
import SankeyInfo from './SankeyInfo';

export default class SankeyChart extends Component {
	constructor(props) {
		super(props)
		this.state= {
			nodes: SankeyInfo.nodes,
      		links: SankeyInfo.links,
      		width: this.props.width,
      		height: this.props.height,
		}
	}

	componentWillMount() {
	}
	
	_renderSankeyHint() {
	    let activeLink = this.state.activeLink
	    if (activeLink== null) return;

	    const x = activeLink.source.x1 + ((activeLink.target.x0 - activeLink.source.x1) / 2);
	    const y = activeLink.y0 - ((activeLink.y0 - activeLink.y1) / 2);
	    const hintValue = {};
	    const label = `${activeLink.source.name} ➞ ${activeLink.target.name}`;
	    hintValue[label] = activeLink.value.toLocaleString();

	    return (
	      <Hint x={x} y={y} value={hintValue} />
	    );
	}

	render() {
		const links = this.state.links;
    	const nodes = this.state.nodes;
		return ( 
			<Sankey
	            className="Sankey"
	            nodes={nodes}
	            links={links.map((d, i) => ({...d,
	                color: this.state.linkIndex === i ? '#ffa24c' : "#98e2e1"
	            }))}
	            width={this.state.width}
	            height={this.state.height}
	            onLinkMouseOver={(point, e) => {
	              this.setState({
	                linkIndex: point.index,
	                activeLink: point
	              })
	            }}
	            onLinkMouseOut={(point, e) => {
	              this.setState({
	                linkIndex: null,
	                activeLink: null
	              })
	            }}>
	            {this._renderSankeyHint()}
	          </Sankey>
		);
	}
}