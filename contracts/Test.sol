pragma solidity ^0.5.12;

contract Test {
    event SeqIncreased(uint256 seq);

    uint256 public seq = 0;

    function increase(address sender) public {
        require(sender == msg.sender);
        seq++;
        emit SeqIncreased(seq);
    }
}
