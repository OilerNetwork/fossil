// The following code was taken from the Alexandria library and added as internal library to 
// make auditing easier. The original code can be found at https://github.com/keep-starknet-strange/alexandria/blob/main/src/math/src/lib.cairo

use core::integer::{
    BoundedInt, u8_wide_mul, u16_wide_mul, u32_wide_mul, u64_wide_mul, u128_wide_mul,
    u256_overflow_mul
};
use fossil::library::math_utils::pow;

pub trait BitShift<T> {
    fn shl(x: T, n: T) -> T;
    fn shr(x: T, n: T) -> T;
}

pub impl U8BitShift of BitShift<u8> {
    fn shl(x: u8, n: u8) -> u8 {
        (u8_wide_mul(x, pow(2, n)) & BoundedInt::<u8>::max().into()).try_into().unwrap()
    }

    fn shr(x: u8, n: u8) -> u8 {
        x / pow(2, n)
    }
}

pub impl U16BitShift of BitShift<u16> {
    fn shl(x: u16, n: u16) -> u16 {
        (u16_wide_mul(x, pow(2, n)) & BoundedInt::<u16>::max().into()).try_into().unwrap()
    }

    fn shr(x: u16, n: u16) -> u16 {
        x / pow(2, n)
    }
}

pub impl U32BitShift of BitShift<u32> {
    fn shl(x: u32, n: u32) -> u32 {
        (u32_wide_mul(x, pow(2, n)) & BoundedInt::<u32>::max().into()).try_into().unwrap()
    }

    fn shr(x: u32, n: u32) -> u32 {
        x / pow(2, n)
    }
}

pub impl U64BitShift of BitShift<u64> {
    fn shl(x: u64, n: u64) -> u64 {
        (u64_wide_mul(x, pow(2, n)) & BoundedInt::<u64>::max().into()).try_into().unwrap()
    }

    fn shr(x: u64, n: u64) -> u64 {
        x / pow(2, n)
    }
}

pub impl U128BitShift of BitShift<u128> {
    fn shl(x: u128, n: u128) -> u128 {
        let (_, bottom_word) = u128_wide_mul(x, pow(2, n));
        bottom_word
    }

    fn shr(x: u128, n: u128) -> u128 {
        x / pow(2, n)
    }
}

pub impl U256BitShift of BitShift<u256> {
    fn shl(x: u256, n: u256) -> u256 {
        let (r, _) = u256_overflow_mul(x, pow(2, n));
        r
    }

    fn shr(x: u256, n: u256) -> u256 {
        x / pow(2, n)
    }
}

