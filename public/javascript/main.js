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
    oraclesCount()
})

function loadContract() {
    const abi = JSON.parse(`[{"constant":true,"inputs":[{"name":"","type":"uint256"}],
        "name":"oracles","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":
        "view","type":"function"},{"constant":false,"inputs":[{"name":"candidate","type":"address"}]
        ,"name":"vote","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":
        "nonpayable","type":"function"},{"constant":false,"inputs":[],
        "name":"becameCandidateToOracles","outputs":[{"name":"","type":"bool"}],"payable":false,
        "stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":
        "oraclesCount","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":
        "view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],
        "name":"voting","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":
        "view","type":"function"},{"constant":false,"inputs":[{"name":"candidate","type":"address"}]
        ,"name":"unvote","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":
        "nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],
        "name":"votes","outputs":[{"name":"initialized","type":"bool"},{"name":"count","type":
        "uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],
        "payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,
        "inputs":[{"indexed":false,"name":"candidate","type":"address"}],"name":
        "BecameCandidateToOracles","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,
        "name":"voter","type":"address"},{"indexed":false,"name":"candidate","type":"address"}],
        "name":"Vote","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"voter",
        "type":"address"},{"indexed":false,"name":"candidate","type":"address"}],"name":"Unvote",
        "type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"newOracle","type":
        "address"},{"indexed":false,"name":"oldOracle","type":"address"}],"name":
        "UpdateOreaclesList","type":"event"}]`)
    const WellcomeContract = window.web3.eth.contract(abi)
    window.contractInstance = WellcomeContract.at('0x0013744908750cdd9e30b22e94377909116ab2b4')
}

$('#oraclesButton').click(function () {
    const address = $('#oraclesAddress').val()
    contractInstance.oracles.call(address, (err, oracle) => {
        if (err) console.error({ err })
        $('#oraclesResult').text(oracle)
    })
})

$('#votingButton').click(function () {
    const address = $('#votingAddress').val()
    contractInstance.voting.call(address, (err, voted) => {
        if (err) console.error({ err })
        $('#votingResult').text(voted)
    })
})

$('#votes').click(function () {
    const address = $('#votesAddress').val()
    contractInstance.votes.call(address, (err, votes) => {
        if (err) console.error({ err })
        // console.log({ votes })
        $('#wantToBeOracle').text(votes[0])
        $('#votesForAddress').text(votes[1].toNumber())
    })
})

$('#becomeCandidate').click(function () {
    getAccount()
        .then((address, err) => {
            if (err) console.error({ err })
            contractInstance.becameCandidateToOracles({ from: address }, function(err, receipt) {
                if (err) console.error({ err })
                // console.log({ receipt })
                handleEvent('BecameCandidateToOracles')
                    .then((event, err) => {
                        if (err) console.error({ err })
                        console.log({ event })
                        $('#becomeCandidateStatus').text('success')
                    })
            })
        })
})

$('#vote').click(function () {
    const forAddress = $('#voteAddress').val()
    getAccount()
        .then((address, err) => {
            if (err) console.error({ err })
            contractInstance.vote(forAddress, { from: address }, function (err, receipt) {
                if (err) console.error({ err })
                // console.log({ receipt })
                handleEvent('Vote')
                    .then((event, err) => {
                        if (err) console.error({ err })
                        console.log({ event })
                        $('#voteForCandidate').text('success')
                    })
            })
        })
})

$('#unvoteButton').click(function () {
    const forAddress = $('#unvoteAddress').val()
    getAccount()
        .then((address, err) => {
            if (err) console.error({ err })
            contractInstance.unvote(forAddress, { from: address }, function (err, receipt) {
                if (err) console.error({ err })
                // console.log({ receipt })
                handleEvent('Unvote')
                    .then((event, err) => {
                        if (err) console.error({ err })
                        console.log({ event })
                        $('#unvoteStatus').text('success')
                    })
            })
        })
})

function handleEvent(eventName) {
    return new Promise((resolve, reject) => {
        if (web3 && contractInstance) {
            const event = contractInstance[eventName]()
            event.watch(function (err, res) {

                if (err) reject(err)

                //         Callback return
                //         Object - An event object as follows:

                //         address: String, 32 Bytes - address from which this log originated.
                //         args: Object - The arguments coming from the event.
                //         blockHash: String, 32 Bytes - hash of the block where this log was in. null when its pending.
                //         blockNumber: Number - the block number where this log was in. null when its pending.
                //         logIndex: Number - integer of the log index position in the block.
                //         event: String - The event name.
                //         removed: bool - indicate if the transaction this event was created from was removed from the blockchain (due to orphaned block) or never get to it (due to rejected transaction).
                //         transactionIndex: Number - integer of the transactions index position log was created from.
                //         transactionHash: String, 32 Bytes - hash of the transactions this log was created from.

                // event arguments cointained in result.args object
                // const { candidateAddress } = res.args
                // console.log({ res })
                resolve(res)
                // new data have arrived. it is good idea to udpate data & UI
                // addNewDataToStateAndUpdateUI()
            })
        }
    })
}

function oraclesCount() {
    contractInstance.oraclesCount.call((err, count) => {
        if (err) console.error({ err })
        $('#oracles').text(count)
    })
}

function getAccount() {
    return new Promise((resolve, reject) => {
        web3.eth.getAccounts(function (err, accounts) {
            if (err) reject(err)
            resolve(accounts[0])
        })
    })
}