pub type Words64 = Span<u64>;
pub type BlockRLP = Span<u8>;

#[derive(Default, Drop, Serde, starknet::Store)]
pub struct Keccak256Hash {
    pub value: u256
}

/// An enum representing the different options for processing account data.
///
/// `OptionsSet` is used to specify which aspect of the account data should be processed or verified.
/// This enum is utilized in functions that handle account proofs and storage data.
#[derive(Drop, Serde)]
pub enum OptionsSet {
    All,
    StorageHash,
    CodeHash,
    Nonce,
    Balance,
}

/// Struct representing a sequence of 64-bit words with a specified length in bytes.
///
/// # Fields
/// * `values` - The sequence of 64-bit words (`Words64`).
/// * `len_bytes` - The length of the sequence in bytes.
/// 
/// `Words64Sequence` is used to encapsulate a sequence of `Words64`
/// along with the length of the sequence in bytes.
#[derive(Copy, Drop, Serde)]
pub struct Words64Sequence {
    pub values: Words64,
    pub len_bytes: usize,
}

///  Struct representing an item in an RLP-encoded list.
///
/// # Fields
/// * `first_byte`- The first byte of the RLP item.
/// * `position` - The position of the RLP item within the encoded sequence.
/// * `length` - The length of the RLP item in bytes.
/// 
/// This struct is used to store metadata about a specific item within an RLP-encoded sequence,
/// including its first byte, position within the sequence, and length.
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

#[derive(Drop, Serde)]
pub struct MMRProof {
    pub element_index: usize,
    pub element_hash: u256,
    pub siblings: Span<u256>,
    pub peaks: Span<u256>,
    pub elements_count: usize,
}

/// Implementation of `PartialEq` for `Words64Sequence`.
///
/// # Methods
/// * `eq` - Checks if two `Words64Sequence` instances are equal by comparing their `values`.
/// * `ne` - Checks if two `Words64Sequence` instances are not equal by comparing their `values`.
impl Words64SequencePartialEq of PartialEq<Words64Sequence> {
    fn eq(lhs: @Words64Sequence, rhs: @Words64Sequence) -> bool {
        *lhs.values == *rhs.values
    }
    fn ne(lhs: @Words64Sequence, rhs: @Words64Sequence) -> bool {
        *lhs.values != *rhs.values
    }
}
