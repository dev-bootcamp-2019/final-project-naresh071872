import React, { Component } from "react";
import Navigation from "../../components/navigation";
import "./admin.css";

class AdminPage extends Component {
  constructor() {
    super();
    this.state = {
      adminAddress: "",
      storeOwnerAddress: "",
      administrators: null,
      storeOwners: null
    };
    this.addAdmin = this.addAdmin.bind(this);
    this.addStoreOwner = this.addStoreOwner.bind(this);
    this.onAddressChange = this.onAddressChange.bind(this);
    this.refreshData = this.refreshData.bind(this);
  }
  async listenToContractEvents() {
    const { contract } = this.props;
    contract.on("LogAdminAdded", this.refreshData);
    contract.on("LogAdminDeleted", this.refreshData);
    contract.on("LogStoreOwnerAdded", this.refreshData);
    contract.on("LogStoreOwnerDeleted", this.refreshData);
  }
  async refreshData() {
    const { contract, onOwnershipChange } = this.props;
    const [administrators, storeOwners] = await Promise.all([
      contract.getAdministrators(),
      contract.getStoreOwners()
    ]);
    this.setState({ administrators, storeOwners });
  }

  componentDidMount() {
    this.refreshData();
    this.listenToContractEvents();
  }

  deleteAdmin(address) {
    const { contract, onOwnershipChange } = this.props;
    return async () => {
      try {
        await contract.deleteAdmin(address);
        onOwnershipChange();
        setTimeout(() => {
          this.refreshData();
        }, 5000);
      } catch (e) {
        console.log(e);
      }
    };
  }

  deleteStoreOwner(address) {
    const { contract, onOwnershipChange } = this.props;
    return async () => {
      try {
        await contract.deleteStoreOwner(address);
        onOwnershipChange();
        setTimeout(() => {
          this.refreshData();
        }, 5000);
      } catch (e) {
        console.log(e);
      }
    };
  }

  async addAdmin(address) {
    const { contract, onOwnershipChange } = this.props;
    const { adminAddress } = this.state;
    try {
      await contract.addAdmin(adminAddress);
      onOwnershipChange();
      setTimeout(() => {
        this.refreshData();
      }, 5000);
    } catch (e) {
      console.log(e);
    }
  }

  async addStoreOwner(address) {
    const { contract, onOwnershipChange } = this.props;
    const { storeOwnerAddress } = this.state;
    try {
      await contract.addStoreOwner(storeOwnerAddress);
      onOwnershipChange();
      setTimeout(() => {
        this.refreshData();
      }, 5000);
    } catch (e) {
      console.log(e);
    }
  }

  renderList(type) {
    const typeToList = this.state[type];
    if (!typeToList || typeToList.length === 0)
      return <div className="listIsEmpty">no {type} yet</div>;
    return (
      <ul>
        {typeToList.map((address, i) => {
          return (
            <li key={i}>
              <div>
                <span>{address}</span>
                <button
                  onClick={
                    type === "administrators"
                      ? this.deleteAdmin(address)
                      : this.deleteStoreOwner(address)
                  }
                >
                  Remove
                </button>
              </div>
            </li>
          );
        })}
      </ul>
    );
  }

  onAddressChange(type) {
    return e => {
      if (type === "administrators") {
        this.setState({ adminAddress: e.target.value });
      } else {
        this.setState({ storeOwnerAddress: e.target.value });
      }
    };
  }

  renderAddSection(type) {
    return (
      <div>
        <h4>Add {type} </h4>
        <div>
          <input
            onChange={this.onAddressChange(type)}
            type="text"
            placeholder={"0x012334...."}
          />
          <button
            onClick={
              type === "administrators" ? this.addAdmin : this.addStoreOwner
            }
          >
            Add
          </button>
        </div>
      </div>
    );
  }

  renderSections() {
    return ["administrators", "storeOwners"].map(type => {
      return (
        <div key={type} className="panelSection">
          <h2>{type}</h2>
          {this.renderList(type)}
          {this.renderAddSection(type)}
        </div>
      );
    });
  }

  render() {
    const { accounts, isAdmin, isStoreOwner } = this.props;
    return (
      <div>
        <Navigation isAdmin={isAdmin} isStoreOwner={isStoreOwner} />
        <h1>Admin Page</h1>
        <div>Your address: {accounts[0]}</div>
        <div>{this.renderSections()}</div>
      </div>
    );
  }
}

export default AdminPage;
