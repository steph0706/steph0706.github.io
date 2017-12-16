import React, { Component } from 'react';
import {
  XYPlot, 
  XAxis, YAxis, 
  HorizontalGridLines, VerticalGridLines, 
  VerticalBarSeries,
  Hint,
  DiscreteColorLegend,
} from 'react-vis';
import '../node_modules/react-vis/dist/style.css';
import styles from './App.css';
import {csv} from 'd3-request';
import HintContent from './hintcontent.js';


export default class Barchart extends Component {
    constructor(props) {
        super(props);
        this.state= {
          lineVal:null,
          barchart: [],
          ymax: 1300,
          l1:null,
          l2:null,
        };
        this._drawChart = this._drawChart.bind(this);
    }


    componentWillMount() {
        this.setState({l1: this.props.l1, l2: this.props.l2});
        this._drawChart(this.props.l1, this.props.l2, null);
        
    }

    _drawChart(data1, data2, val) {
        var barchart=[];
        var d1 = data1;
        var d2 = data2;
        if (d1){
          d1 = data1.map((d, i) => ({...d, 
            color: (val != null && (d.x === val.x && d.y === val.y)) ? 2 : 0}));
        }

        if (d2) {
          d2 = data2.map((d, i) => ({...d, 
            color: (val != null && (d.x === val.x && d.y === val.y)) ? 2 : 1}));
        }
        
        
        barchart.push(
            <VerticalBarSeries
              data={d1}
              animation="wobbly"
              onValueMouseOver={(datapoint, {index}) => {
                this.setState({lineVal:datapoint});
                this._drawChart(this.props.l1, this.props.l2, datapoint);
              }}
              onValueMouseOut={() => {
                this.setState({lineVal:null});
                this._drawChart(this.props.l1, this.props.l2, null);

              }}

            />
        );
        barchart.push(
            <VerticalBarSeries
              data={d2}
              // color="#17a5a3"
              // stroke="white"
              animation="wobbly"
              style={{float: "left"}}
              onValueMouseOver={(datapoint, {index}) => {
                this.setState({lineVal:datapoint});
                this._drawChart(this.props.l1, this.props.l2, datapoint)
              }}
              onValueMouseOut={() => {
                this.setState({lineVal:null});
                this._drawChart(this.props.l1, this.props.l2, null);

              }}
            />
        );
        this.setState({barchart:barchart});

    }

    componentWillReceiveProps(nextProps) {
      if(JSON.stringify(this.props.l1) !== JSON.stringify(nextProps.l1)) {
          this.setState({l1: nextProps.l1, l2: nextProps.l2});
          this._drawChart(nextProps.l1, nextProps.l2);
      }
    } 

    render() {
        const lineVal = this.state.lineVal;
        return (<div>
            <XYPlot className="lineChart"
                width={Number(this.props.width)}
                height={Number(this.props.height)}
                xType="ordinal"
                yType="linear"
                colorDomain={[0, 1, 2]}
                colorRange={["#98e2e1","#17a5a3", "#ffa24c"]}
                yDomain={[0, this.props.ymax]}
                margin={{bottom:70}}
                flex={1}
                onMouseLeave={() => {
                  this.setState({lineVal:null});
                  this._drawChart(this.props.l1, this.props.l2, null);
                }}
                >
                
                <DiscreteColorLegend 
                    items = {[
                      {title: "L1 speakers", color: "#98e2e1"},
                      {title: "L2 speakers", color: "#17a5a3"}
                    ]}
                    width = {100}
                    className="legend"
                />
                
              <HorizontalGridLines />
              <VerticalGridLines />
              <YAxis />
              <XAxis tickLabelAngle={-70}/>
              
              {this.state.barchart ? this.state.barchart : null}
              {
                lineVal ? 
                <Hint value={lineVal} style= {{   
                      background: "#353535",
                      color: 'white',
                      fontSize: "10px",
                      padding: "10px",
                      borderRadius: "3px",
                      width: "110px",
                       }}>
                  <HintContent value={lineVal} />
                    
                </Hint> : null
              }
                               
            </XYPlot>
        </div>);

    }


}