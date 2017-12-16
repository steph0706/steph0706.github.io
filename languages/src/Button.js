import React, { Component} from 'react';
import styles from './index.css';
export default class Button extends Component {
    constructor(props) {
        super(props);
    }

    _toggle() {
        console.log("hihi");
    }

    render() {
        return ( <div>
            <label className="switch">
                <input type="checkbox" id="togBtn" onClick={this.props.handler}/>
                <div className="slider round">
                <span className="on">{this.props.label1}</span>
                <span className="off">{this.props.label2}</span>
                </div>
            </label>

        </div>);
    }
}