pragma solidity ^0.4.0;

contract SimpleEscrow {
    uint balance;
    address public buyer;
    address public seller;
    address private escrow;
    uint private start;
    bool buyerOk;
    bool sellerOk;


    function SimpleEscrow(address buyer_address, address seller_address){
        buyer = buyer_address;
        seller = seller_address;
        escrow = msg.sender;
    }


    function getBuyerAddress() public view returns (address){ //. Calling a view cannot alter the behaviour of future interactions with any contract. This means such functions cannot use SSTORE, cannot send or receive ether and can only call other view or pure functions.
        return buyer;
    }
    function getSellerAddress() public view returns (address){ //. Calling a view cannot alter the behaviour of future interactions with any contract. This means such functions cannot use SSTORE, cannot send or receive ether and can only call other view or pure functions.
        return seller;
    }

    function getDepositedAmount() public view returns (uint){
        return balance;
    }


    function accept() public {
        if (msg.sender == buyer) {
            buyerOk = true;
        } else if (msg.sender == seller) {
            sellerOk = true;
        }
        if (buyerOk && sellerOk) {
            payBalance();
        } else if (buyerOk && !sellerOk && now > start + 30 days) {
            // Freeze 30 days before release to buyer. The customer has to remember to call this method after freeze period.
            selfdestruct(buyer);
        }
    }

    function payBalance() private {
        // we are sending ourselves (contract creator) a fee
        escrow.transfer(this.balance / 100);

        if (seller.send(this.balance)) {// if send fails it returns false. This is needed to control the logic (in order to reset the balance to 0)
            balance = 0;
        } else {
            throw;
            // When a contract is firing an exception (via throw / require / assert), the transaction and all change to the state are reverted . Any ether that was sent during the transaction will not be transferred .

        }
    }

    function deposit() public payable {
        //if (msg.sender == buyer) {
            balance += msg.value;
            // if somebody other than the buyer deposits money to this smart contract the deposited money will be lost
        //}
    }

    function cancel() public {
        if (msg.sender == buyer) {
            buyerOk = false;
        } else if (msg.sender == seller) {
            sellerOk = false;
        }
        // if both buyer and seller would like to cancel, money is returned to buyer
        if (!buyerOk && !sellerOk) {
            selfdestruct(buyer);
        }
    }

    function refundBuyer() private {// only we (the escrow can refund the buyer if there is a dispute )
        if (msg.sender == escrow) {
            escrow.transfer(this.balance / 100);
            selfdestruct(buyer);
        }
    }

    function kill() public constant {
        if (msg.sender == escrow) {
            selfdestruct(buyer);
        }
    }
}
