pragma solidity ^0.4.16;
contract OwnedToken {
    // TokenCreator is a contract type that is defined below.
    // It is fine to reference it as long as it is not used
    // to create a new contract������������û������ģ�ֻҪ�����ڴ����º�Լ��.
    TokenCreator creator;
    address owner;
    bytes32 name;
    // This is the constructor which registers the
    // creator and the assigned name.�����캯���ǼǺ�Լ��creator�͸�ֵ��Լ�����ƣ�
    function OwnedToken(bytes32 _name) public {
        // State variables are accessed via their name��״̬����ͨ���������ã�
        // and not via e.g. this.owner. This also applies
        // to functions and especially in the constructors,����������״̬����Ҳ��һ���ģ�ͨ���������ã�
        // you can only call them like that ("internally"),
        // because the contract itself does not exist yet.
        owner = msg.sender;
        // We do an explicit type conversion from `address`
        // to `TokenCreator` and assume that the type of
        // the calling contract is TokenCreator, there is
        // no real way to check that.
//1������������ʾ������ת������addressת��TokenCreator���������˼����ǣ�TokenCreator�����˺�Լ��
//2����TokenCreator���������˱���Լ����Ϊ�����msg.sender�Ǹú�Լ�Ĵ����ߣ�ͬʱת����TokenCreator��
//3����TokenCreator��Լ���������µĺ�Լ(����Լ)��?
        creator = TokenCreator(msg.sender);
        name = _name;
    }
    function changeName(bytes32 newName) public {
        // Only the creator can alter the name --
        // the comparison is possible since contracts
        // are implicitly convertible to addresses.����Լ������ʽת�ɺ�Լ��address��
        if (msg.sender == address(creator))
            name = newName;
    }
    function transfer(address newOwner) public {
        // Only the current owner can transfer the token.
        if (msg.sender != owner) return;
        // We also want to ask the creator if the transfer
        // is fine. Note that this calls a function of the
        // contract defined below. If the call fails (e.g.
        // due to out-of-gas), the execution here stops
        // immediately.
        if (creator.isTokenTransferOK(owner, newOwner))
            owner = newOwner;
    }
}
contract TokenCreator {
    function createToken(bytes32 name)
       public
       returns (OwnedToken tokenAddress)
    {
        // Create a new Token contract and return its address.
        // From the JavaScript side, the return type is simply
        // `address`, as this is the closest type available in
        // the ABI.
        return new OwnedToken(name);//������Լ������Ϣ��OwnedToken��Լ��msg.sender���Ǳ���Լ��
    }
    function changeName(OwnedToken tokenAddress, bytes32 name)  public {
        // Again, the external type of `tokenAddress` is
        // simply `address`.
        tokenAddress.changeName(name);
    }
    function isTokenTransferOK(address currentOwner, address newOwner)
        public
        view
        returns (bool ok)
    {
        // Check some arbitrary condition.
        address tokenAddress = msg.sender;
        return (keccak256(newOwner) & 0xff) == (bytes20(tokenAddress) & 0xff);
    }
}