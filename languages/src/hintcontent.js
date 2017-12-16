import React from 'react';
export default function HintContent({value}) {
  return <div>
    <div style={{position: 'relative', width: '100%'}}>
      <div style={{position: 'relative', textAlign: 'center'}}>{value.name}</div>
    </div>
    <div style={{position: 'relative', height:"17px", width: '100%', marginBottom:'1px'}}>
      <div style={{position: 'absolute', right: 0}}>Number of speakers {value.y}</div>
    </div>
  </div>;
}