import React, { Component } from 'react';
class Shopping extends React.Component {
    constructor(props) {
      super(props);
      this.state = {stores: '',: ''};
  
     
    }
  
   
  
    render() {
      return (
        <form >
            <label>
          Select Product:
          <select value={this.state.value} onChange={this.handleChange}>
            <option value="grapefruit">Grapefruit</option>
            <option value="lime">Lime</option>
            <option value="coconut">Coconut</option>
            <option value="mango">Mango</option>
          </select>
        </label>
        <input type="submit" value="Submit" />
        </form>
      );
    }
  }
  export default Shopping