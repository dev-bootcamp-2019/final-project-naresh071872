import React, { Component } from 'react';
class MarketPlaceForm extends React.Component {
    constructor(props) {
      super(props);
      this.state = {adminAddress: '',storeOwnerAddress: ''};
  
      this.handleAdminAddressChange = this.handleAdminAddressChange.bind(this);
      this.addAdmin = this.addAdmin.bind(this);
      this.handleStoreOwnerAddressChange = this.handleStoreOwnerAddressChange.bind(this);
      this.addStoreOwner= this.addStoreOwner.bind(this);
    }
  
    handleAdminAddressChange(event) {
      this.setState({adminAddress: event.target.value});
    }
    handleStoreOwnerAddressChange(event) {
      this.setState({storeOwnerAddress: event.target.value});
    }
  
    addAdmin(event) {
      alert('A name was submitted: ' + this.state.adminAddress);
      event.preventDefault();
    }
    addStoreOwner(event) {
      alert('A name was submitted: ' + this.state.storeOwnerAddress);
      event.preventDefault();
    }
  
    render() {
      return (
        <form >
          <label>
            AdminAddress:
            <input size="60" type="text" value={this.state.adminAddress} 
            onChange={this.handleAdminAddressChange} />

          <button onClick={this.addAdmin}>Add</button>
          </label>
          <p></p>
          <label>
            StoreOwnerAddress:
            <input size="60" type="text" value={this.state.storeOwnerAddress} 
            onChange={this.handleStoreOwnerAddressChange} />
          </label>
          <button onClick={this.addStoreOwner}>Add</button>
          <p></p>
        </form>
      );
    }
  }
  export default MarketPlaceForm