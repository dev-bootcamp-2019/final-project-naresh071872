import React, { Component } from "react";
import { ethers } from "ethers";
import { Link } from "react-router-dom";
import Navigation from "../../components/navigation";
import "./storeOwner.css";

class StoreOwnerPage extends Component {
  constructor() {
    super();
    this.state = {
      stores: null,
      storeName: ""
    };
    this.onStoreNameChange = this.onStoreNameChange.bind(this);
    this.createStore = this.createStore.bind(this);
    this.deleteStore = this.deleteStore.bind(this);
    this.withdrawBalance = this.withdrawBalance.bind(this);
    this.refreshData = this.refreshData.bind(this);
  }

  async listenToContractEvents() {
    const { contract } = this.props;
    contract.on("LogAddStore", this.refreshData);
    contract.on("LogDeleteStore", this.refreshData);
    contract.on("LogWithdrawFunds", this.refreshData);
  }

  async refreshData() {
    const { contract, accounts } = this.props;
    const [ids, names, balances] = await contract.findStoresByOwner(
      accounts[0]
    );
    let stores = [];
    ids.forEach((idHex, i) => {
      const storeId = idHex;
      const name = ethers.utils.parseBytes32String(names[i]);
      const storeSales = ethers.utils.formatEther(balances[i]);
      stores.push({ storeId, name, storeSales });
    });
    this.setState({ stores });
  }
  componentDidMount() {
    this.refreshData();
    this.listenToContractEvents();
  }

  async createStore() {
    const { storeName } = this.state;
    const { contract } = this.props;
    if (!storeName || storeName === "") return;
    try {
      const nameToBytes32 = ethers.utils.formatBytes32String(storeName);
      await contract.addStore(nameToBytes32);
    } catch (e) {
      console.log(e);
    }
  }

  onStoreNameChange(e) {
    this.setState({ storeName: e.target.value });
  }

  deleteStore(storeId) {
    return async () => {
      const { contract } = this.props;
      try {
        await contract.deleteStore(storeId);
      } catch (e) {
        console.log(e);
      }
    };
  }

  withdrawBalance(storeId) {
    return async () => {
      const { contract } = this.props;
      try {
        await contract.withdrawFunds(storeId, {
          gasLimit: 150000
        });
      } catch (e) {
        console.log(e);
      }
    };
  }

  renderStoreListSection() {
    const { stores } = this.state;
    if (!stores || stores.length === 0)
      return (
        <div style={{ marginTop: "40px" }}>You don't have any stores yet.</div>
      );
    return (
      <div className="panelSection">
        <table className="storeTable">
          <thead>
            <tr>
              <th>Name</th>
              <th>Balance(ETH)</th>
              <th />
              <th />
            </tr>
          </thead>
          <tbody>
            {stores.map((store, i) => {
              return (
                <tr key={i}>
                  <td>
                    <Link to={`/store/${store.storeId}`}>{store.name}</Link>
                  </td>
                  <td>{store.balance}</td>
                  <td>
                    <button onClick={this.deleteStore(store.storeId)}>
                      Remove
                    </button>
                  </td>
                  <td>
                    <button onClick={this.withdrawBalance(store.storeId)}>
                      Withdraw balance
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    );
  }

  renderAddStoreSection() {
    return (
      <div>
        <h4>Create a new store</h4>
        <input
          className="storeNameInput"
          type="text"
          placeholder="Please enter a store name"
          onChange={this.onStoreNameChange}
        />
        <button onClick={this.createStore}>Create</button>
      </div>
    );
  }

  render() {
    const { accounts, isAdmin, isStoreOwner } = this.props;
    return (
      <div className="marketPlace">
        <Navigation isAdmin={isAdmin} isStoreOwner={isStoreOwner} />
        <h1>Store Owner page</h1>
        <div>Your address: {accounts[0]}</div>
        <div>{this.renderStoreListSection()}</div>
        <div>{this.renderAddStoreSection()}</div>
      </div>
    );
  }
}

export default StoreOwnerPage;
