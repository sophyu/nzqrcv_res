pragma solidity ^0.4.16;
contract OwnedToken {
    // TokenCreator is a contract type that is defined below.
    // It is fine to reference it as long as it is not used
    // to create a new contract（定义引用是没有问题的，只要不用于创建新合约）.
    TokenCreator creator;
    address owner;
    bytes32 name;
    // This is the constructor which registers the
    // creator and the assigned name.（构造函数登记合约的creator和赋值合约的名称）
    function OwnedToken(bytes32 _name) public {
        // State variables are accessed via their name（状态变量通过名称引用）
        // and not via e.g. this.owner. This also applies
        // to functions and especially in the constructors,（函数引用状态变量也是一样的，通过名称引用）
        // you can only call them like that ("internally"),
        // because the contract itself does not exist yet.
        owner = msg.sender;
        // We do an explicit type conversion from `address`
        // to `TokenCreator` and assume that the type of
        // the calling contract is TokenCreator, there is
        // no real way to check that.
//1、这里做了显示的类型转换，将address转成TokenCreator，这里做了假设是，TokenCreator创建了合约；
//2、是TokenCreator调用生成了本合约；因为下面的msg.sender是该合约的创建者，同时转成了TokenCreator；
//3、是TokenCreator合约调用生成新的合约(本合约)；?
        creator = TokenCreator(msg.sender);
        name = _name;
    }
    function changeName(bytes32 newName) public {
        // Only the creator can alter the name --
        // the comparison is possible since contracts
        // are implicitly convertible to addresses.（合约可以隐式转成合约的address）
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
        return new OwnedToken(name);//创建合约，发消息给OwnedToken合约，msg.sender就是本合约了
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