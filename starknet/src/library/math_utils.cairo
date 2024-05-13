fn min(a: usize, b: usize) -> usize {
    if a < b {
        return a;
    }
    return b;
}

/// Raise a number to a power.
/// O(log n) time complexity.
/// * `base` - The number to raise.
/// * `exp` - The exponent.
/// # Returns
/// * `T` - The result of base raised to the power of exp.
pub fn pow<T, +Sub<T>, +Mul<T>, +Div<T>, +Rem<T>, +PartialEq<T>, +Into<u8, T>, +Drop<T>, +Copy<T>>(
    base: T, exp: T
) -> T {
    if exp == 0_u8.into() {
        1_u8.into()
    } else if exp == 1_u8.into() {
        base
    } else if exp % 2_u8.into() == 0_u8.into() {
        pow(base * base, exp / 2_u8.into())
    } else {
        base * pow(base * base, exp / 2_u8.into())
    }
}
