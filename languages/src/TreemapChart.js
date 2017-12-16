import React, { Component} from 'react';
import {
  Hint,
  Treemap
} from 'react-vis';
import './App.css';
import LanguageFamilyData from './languageHierarchy.json'

export default class TreemapChart extends Component {
	constructor(props) {
		super(props);
		this.state = {
			treePath: [],
			width: this.props.width,
			height: this.props.height
		}
	
	}
	_handleTreemapHover(node) {
	    this.setState({
	      hovered: node
	    });
	    console.log(node)

	    node.data.color = 1;
	 }

	_showLanguage() {
		if (this.state.hovered) {
			return this.state.hovered.data.title + ": " + this.state.hovered.data.size + " languages";
		}

		return "";
	}

	render() {
		return (
			<div>
			<Treemap
				title={'Language Family Treemap'}
				width={this.props.width}
				height={this.props.height}
		        mode="squarify"
		        padding={2}
		        hideRootNode={true}
		        onLeafMouseOver={(node, e) => this._handleTreemapHover(node)}
		        onLeafMouseOut={(node, e) => {
		          this.setState({hovered: null});
		          node.data.color = 0;
		        }}
		        colorDomain={[0,1]}
		        colorRange={["#98e2e1", "#ffa24c"]}
				data={LanguageFamilyData}
				>
		    </Treemap>
		    <h3>{ this._showLanguage() }</h3>
		    </div>
		)
	}
}