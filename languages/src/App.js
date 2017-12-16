import React, { Component} from 'react';
import {
  XYPlot, 
  XAxis, YAxis, 
  HorizontalGridLines, VerticalGridLines, 
  VerticalBarSeries,
  Hint,
  DiscreteColorLegend,
  Treemap
} from 'react-vis';
import './App.css';
import ReactMapboxGl, { Layer, Feature, GeoJSONLayer } from "react-mapbox-gl";
import '../node_modules/react-vis/dist/style.css';
import styles from './App.css';
import {csv} from 'd3-request';
import d3 from 'd3';

import Barchart from './Barchart';
import Button from './Button';

import englishGeoJSON from './englishSpeakingCountries.json';
import chineseGeoJSON from './chineseSpeakingCountries.json';

const Map = ReactMapboxGl({
  accessToken: 'pk.eyJ1IjoidnRyYW4wMSIsImEiOiJjamFvZXcwbXAwaDNkMzNwZm01eG10MHhkIn0.HMWFx0t9PAyxpG0EV6P6lg'
});

class App extends Component {
  constructor(props) {
    super(props);
    this.state= {
      toggled:false,
      l1: null,
      l2: null,
      l12: null,
      l22: null,
      ymax: 0,
      loadError:false,
      data:null,
      width:null,
      height:null,
      box:null,
      barchart:null,
      bubble:null,
      currSer:null,
      mapLayer: null  // 1: anglosphere, 2: chinese-speaking countries, 3: non-top language speaking countries
      
    };

    this._toggle = this._toggle.bind(this);
    this.updateDimensions = this.updateDimensions.bind(this);
  }

  state = {
          year: 2015,
          data: null,
          hoveredFeature: null,
          viewport: {
            latitude: 40,
            longitude: -100,
            zoom: 3,
            bearing: 0,
            pitch: 0,
            width: 500,
            height: 500
          }
      };

  _onViewportChange(viewport) {
    this.setState({
      zoom: 8,
      latitude: viewport.latitude,
      longitude: viewport.longitude,
    })
  }

  componentWillMount() {
      this.setState({mapLayer: this.props.mapLayer});
      var file1 = "l1l2.csv";
      var max = 0;
      csv(file1, (error, d) => {
        if (error) this.setState({loadError: true});
        else {
          let l1 = [];
          let l2 = [];
          for (var i = 0; i < d.length; i++){
            let vals = Object.values(d[i]);
            max = Math.max(vals[3], Math.max(max, vals[4]));
            l1.push( {
              x: String(vals[1]),
              y: Number(vals[3]),
              name: vals[2]
            });
            l2.push({
              x: String(vals[1]),
              y: Number(vals[4]),
              name: vals[2]
            });
          }
          this.setState({l1:l1, l2:l2});
        }

      });

      let file2 = "l2l1.csv";
      csv(file2, (error, d) => {
      if (error) this.setState({loadError: true});
      else {
        let l12 = [];
        let l22 = [];
        for (let i = 0; i < d.length; i++){
          var vals = Object.values(d[i]);
          max = Math.max(vals[3], Math.max(max, vals[4]));
          l12.push( {
            x: String(vals[1]),
            y: Number(vals[3]),
            name: vals[2]
          });
          l22.push({
            x: String(vals[1]),
            y: Number(vals[4]),
            name: vals[2]
          });
        }
        this.setState({l12: l12, l22: l22, ymax:max});
      }

    });

    this.setState({height: this.props.height.slice(0, -2), width: this.props.width.slice(0, -2)});
    this.setState({box:this.props.boxId});

  }

  componentDidMount() {
    window.addEventListener("resize", this.updateDimensions);
  }

  componentWillReceiveProps(nextProps) {
    if(this.props.boxId !== nextProps.boxId) {
      if (Number(this.props.boxId) == 2 && Number(nextProps.boxId) == 3 ||
        Number(this.props.boxId) == 3 && Number(nextProps.boxId) == 2){
        this._toggle();
      } else if (Number(this.props.boxId) == -1 && Number(nextProps.boxId) == 0){
        this.setState({mapLayer:1});
      } else if (Number(this.props.boxId) == 0 && Number(nextProps.boxId) == 1 ) {
        this.setState({mapLayer:2});
      } else if (Number(this.props.boxId) == 1 && Number(nextProps.boxId) == 0) {
        this.setState({mapLayer:1});
      } 
      this.setState({box: nextProps.boxId});
    }
  }

  updateDimensions() {
    let elem = document.getElementById('root').style;
    this.setState({width: elem.width.slice(0, -2), height: elem.height.slice(0,-2)});
  }

  _renderMap() {
		return (
      <Map
        className="Map"
        style="mapbox://styles/mapbox/streets-v9"
        zoom={this.state.mapLayer === 0 ? [0] : [.75]}
        center={[0, 36]}
        containerStyle={{
          height: String(this.state.height) + "px",
          width: String(this.state.width) + "px"
        }}>

        <GeoJSONLayer
          data={englishGeoJSON}
          id="englishSpeaking"
          fillLayout={{ visibility: this.state.mapLayer === 1 ? 'visible' : 'none' }}
          fillPaint={{
            'fill-color': '#4682B4',
            'fill-opacity': 0.5,
            'fill-outline-color': 'blue'
          }}
        />

        <GeoJSONLayer
          data={chineseGeoJSON}
          id="chineseSpeaking"
          fillLayout={{ visibility: this.state.mapLayer === 2 ? 'visible' : 'none' }}
          fillPaint={{
            'fill-color': 'red',
            'fill-opacity': 0.5,
            'fill-outline-color': 'red'
          }}
        />

        <GeoJSONLayer
          data={englishGeoJSON}
          id="nonMajorLanguageSpeaking"
          fillLayout={{ visibility: this.state.mapLayer === 3 ? 'visible' : 'none' }}
          fillPaint={{
            'fill-color': '#FFA500',
            'fill-opacity': 0.5,
            'fill-outline-color': 'orange'
          }}
        />    
      </Map>
		)
	}

  _toggle() {
    if (this.state.l1 != null && this.state.l12 != null) {
      let temp1 = this.state.l1;
      let temp2 = this.state.l2;
      this.setState({l1: this.state.l12, l2: this.state.l22, l12:temp1, l22: temp2});
    }
  }

  render() {
    
    const lineVal = this.state.lineVal;
    if (Number(this.state.box == 5)) {
      return (<div className="App"></div>);
    }
    else return (

		  <div className="App">

        { Number(this.state.box) < 2 ? this._renderMap() : null }

        {
          (this.state.l1 && this.state.l2 && (Number(this.state.box) == 2) || Number(this.state.box) == 3) ? 
          <Barchart l1={this.state.l1} l2={this.state.l2} ymax={this.state.ymax} 
            height={this.state.height} width={this.state.width}  /> : null
        }

      </div>
    );
  }

  
}

export default App;
