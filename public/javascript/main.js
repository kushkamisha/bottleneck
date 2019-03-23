/**
 * @see https://ylv.io/10-web3-metamask-use-cases-ever-blockchain-developer-needs/
 */

$(document).ready(function () {
    if (typeof web3 !== 'undefined') {
        // Use Mist/MetaMask's provider
        window.web3 = new Web3(web3.currentProvider)
    } else {
        window.web3 = new Web3(
            new Web3.providers.HttpProvider('https://localhost:8545')
        )
    }

    loadContract()
    welcomeString()
})

function loadContract() {
    const abi = JSON.parse(`[
	{
    "constant": false,
    "inputs": [
      {
        "name": "newWelcomeString",
        "type": "string"
      }
    ],
    "name": "setWelcomeString",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "welcomeString",
    "outputs": [
      {
        "name": "",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }
]`)
    const WellcomeContract = window.web3.eth.contract(abi)
    window.contractInstance = WellcomeContract.at('0xC108FA335EEc79056c26b9B2A39Fe59fEc6e4D2A')
}

$(':button[value="changeString"]').click(function async() {
    const newString = $('#newString').val()

    // contractInstance.setWelcomeString(newString, { from: '0x4D07e28E9EE6DC715b98f589169d7927239d7318' }, function () {
    //     console.log('yey')
    // });

    // contractInstance.setWelcomeString(newString, { from: '0x4D07e28E9EE6DC715b98f589169d7927239d7318' }, function(err, receipt) {
    //     if (err) console.error({ err })
    //     console.log({ receipt })
    // })

    getAccount()
        .then((account, err) => {
            if (err) console.error({ err })
            contractInstance.setWelcomeString(newString, { from: account }, function(err, receipt) {
                if (err) console.error({ err })
                console.log({ receipt })
            })
        })
})

function welcomeString() {
    contractInstance.welcomeString.call((err, res) => {
        if (err) console.log({ err })
        $("#welcomeString").text(res)
    })
}

function getAccount() {
    return new Promise((resolve, reject) => {
        web3.eth.getAccounts(function (err, accounts) {
            if (err) reject(err)
            resolve(accounts[0])
                // web3.eth.getBalance(accounts[0], function (err, balance) {
                //     if (!err) {
                //         accounts[0]
                //         // balance.toNumber() / 1000000000000000000
                //     } else {
                //         console.error(err);
                //     }
                // });
        })
    })
}
