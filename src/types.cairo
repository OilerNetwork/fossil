pub type Words64 = Span<u64>;

#[derive(Default, Drop, Serde, starknet::Store)]
pub struct Keccak256Hash {
    pub value: u256
}

#[derive(Default, Drop, Serde)]
pub struct StorageSlot {
    value: u256,
}

#[derive(Drop, Serde)]
pub enum OptionsSet {
    StorageHash,
    CodeHash,
    Nonce,
    Balance,
}

#[derive(Copy, Drop, Serde)]
pub struct Words64Sequence {
    pub values: Words64,
    pub len_bytes: usize,
}

#[derive(Debug, Copy, Default, Drop, Serde)]
pub struct RLPItem {
    pub first_byte: u64,
    pub position: usize,
    pub length: u64,
}

#[derive(Copy, Drop, Serde)]
pub enum ProcessBlockOptions {
    UncleHash,
    Beneficiary,
    StateRoot,
    TxRoot,
    ReceiptRoot,
    Difficulty,
    GasUsed,
    TimeStamp,
    BaseFee
}
