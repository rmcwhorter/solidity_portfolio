pragma solidity ^0.8.3;

/**
* We need to be able to send and receive messages. That's it.
*/

// Point Message Protocol

/**
* Basically, the idea is that when [send] is called,
* we go find the contract at the target address, and 
* if this contract implements PMPR, we call [receive]
* on the target contract with the given message. If
* the target contract does not implement PMPR, we
* return false. Otherwise, we return the bool value
* that we got from calling [receive] on the target
* contract.
* CHANGE: Actually, we don't use bools, we use a
* custom enum
*/

/**
* Success: the target implements PMPR, and got the
* message.
* TargetImplFailure: the target does not implement PMPR.
* Is your target address right?
* TargetRecFailure: The target implements PMPR, but 
* failed to receive the message in some other way.
* Is your formatting wrong?
*/

struct MSG {
    address originator;
    string value;
}

enum PMPState {
    Success,
    TargetImplFailure,
    TargetRecFailure
}

/*
* Here's the thing. Any function in an interface has to be <external>. So, 
* a [send] function is <external>. That's real bad, because other people can send
* stuff in our name. So, a propper PointMessagingProtocol should only have recieve
* - I should only tell you how to send me something, how you do that is up to you.
*/
/*
* Version 3
*/
interface PMPF {
    // [recieve] returns true if the message was successfully recieved, false otherwise. 
    function receive(MSG calldata message) external;
}

/*
* Version 2
*/
interface PMPS_2 {
    function send(MSG calldata message, address target) external returns (bool);
}

interface PMPR_2 {
    // [recieve] returns true if the message was successfully recieved, false otherwise. 
    function receive(MSG calldata message) external;
}

interface PMP_2 is PMPS_2, PMPR_2 {}

/*
* Version 1
*/
interface PMPS {
    // [send] returns true if the message was successfully sent, false otherwise.
    function send(string calldata message, address target) external returns (bool);
}

interface PMPR {
    // [recieve] returns true if the message was successfully recieved, false otherwise. 
    function receive(string calldata message) external;
}

// Ethereum Messaging Protocol
interface PMP is PMPS, PMPR {}