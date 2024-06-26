#[derive(Copy, Drop)]
pub struct Block {
    pub number: u64,
    pub state_root: u256,
}


pub fn BLOCK_0() -> Block {
    Block {
        number: 11456152,
        state_root: 0xd45cea1d5cae78386f79e0d522e0a1d91b2da95ff84b5de258f2c9893d3f49b1,
    }
}
pub fn BLOCK_1() -> Block {
    Block {
        number: 11456151,
        state_root: 0x859360abc4f7ba9fab2650b836667de32594f3f2472e71c7f16d7b10fb52790e,
    }
}
pub fn BLOCK_2() -> Block {
    Block {
        number: 11456150,
        state_root: 0xc4f7e42873dd9738f215c16f03abc55dbd27baad86b217afa5f7a7260ea91a79,
    }
}
pub fn BLOCK_3() -> Block {
    Block {
        number: 13843670,
        state_root: 0x2045bf4ea5561e88a4d0d9afbc316354e49fe892ac7e961a5e68f1f4b9561152,
    }
}


pub fn BLOCK_4() -> Block {
    Block {
        number: 13843679,
        state_root: 0x2045bf4ea5561e88a4d0d9afbc316354e49fe892ac7e961a5e68f1f4b9561158,
    }
}
