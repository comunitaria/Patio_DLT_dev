import React, {Component} from 'react'
import SimpleEscrowContract from '../../build/contracts/SimpleEscrow.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

class App extends Component {
    constructor(props) {
        super(props)

        this.state = {
            buyerAddress: null,
            sellerAddress: null,
            addressOfCurrentWallet: null,
            simpleEscrowInstance: null,
            accounts: null,
            amountDeposited: 0,
            amountToDeposit: 0,
            web3: null
        }
    }

    componentWillMount() {
        // Get network provider and web3 instance.
        // See utils/getWeb3 for more info.

        getWeb3
            .then(results => {
                this.setState({
                    web3: results.web3
                })

                // Instantiate contract once web3 provided.
                this.instantiateContract()
            })
            .catch(() => {
                console.log('Error finding web3.')
            })
    }

    instantiateContract() {

        const contract = require('truffle-contract')
        const SimpleEscrow = contract(SimpleEscrowContract)
        SimpleEscrow.setProvider(this.state.web3.currentProvider)

        // Declaring this for later so we can chain functions on SimpleEscrow.
        var SimpleEscrowInstance;

        // Get accounts.
        this.state.web3.eth.getAccounts((error, accounts) => {
            SimpleEscrow.deployed().then((instance) => {
                SimpleEscrowInstance = instance;
                this.setState({simpleEscrowInstance: instance});
                this.setState({accounts: accounts});
                this.setState({addressOfCurrentWallet: accounts[0]})


                SimpleEscrowInstance.getBuyerAddress(accounts[0]).then((result) => {
                    // Update state with the result.
                    console.log('got buyer address: ', result);
                    this.setState({buyerAddress: result});
                });
                SimpleEscrowInstance.getSellerAddress(accounts[0]).then((result) => {
                    // Update state with the result.
                    console.log('got seller address: ', result);
                    this.setState({sellerAddress: result});
                })
                SimpleEscrowInstance.getDepositedAmount(accounts[0]).then((result) => {
                    // Update state with the result.
                    console.log('got deposited amount : ', result.toString(10));
                    this.setState({amountDeposited: result.toString(10)});
                })
            })
        })
    }

    handleAmountToDepositUpdate = (event) => {
        this.setState({amountToDeposit: event.target.value})
    }

    submitNewDepositAmount = () => {
        console.log('the amount to deposit is:', this.state.amountToDeposit, this.state.simpleEscrowInstance, this.state.accounts);
        this.state.simpleEscrowInstance.deposit({
            'from': this.state.accounts[0],
            gas: 3000000,
            value: parseInt(this.state.amountToDeposit)
        }).then((result) => {
            console.log('saved new deposit: ', result);
            this.setState({amountDeposited: this.state.amountToDeposit});
        });
    }


    render() {
        return (
            <div className="App">
                <nav className="navbar pure-menu pure-menu-horizontal">
                    <a href="#" className="pure-menu-heading pure-menu-link">Solidity Escrow</a>
                </nav>

                <main className="container">
                    <div className="pure-g">
                        <div className="pure-u-1-1">
                            <h1>Simple Escrow</h1>
                            <p><strong>buyer address: {this.state.buyerAddress} </strong></p>
                            <p><strong>seller address: {this.state.sellerAddress} </strong></p>
                            <p><strong>your adress is: {this.state.addressOfCurrentWallet} </strong></p>

                            <p>submit a new value as deposit (only the buyer should call this function)</p>
                            <input type="text" name="amountToDeposit" value={this.state.amountToDeposit}
                                   onChange={this.handleAmountToDepositUpdate}/>

                            <button onClick={this.submitNewDepositAmount}> submit new deposit to escrow contract</button>


                            <h2>The current value of the deposit is </h2>
                            <p>{this.state.amountDeposited}</p>

                        </div>
                    </div>
                </main>
            </div>
        );
    }
}

export default App
