// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title BigDataStore
/// @author Luo Yingjie
/// @notice This contract stores a large amount of data in the Contract Bytecode.
contract BigDataStore {
    constructor(bytes memory data) {
        assembly {
            // Reads the first 32 bytes at the memory location `data`
            // Since `bytes` arrays store their length at the first 32 bytes, this retrieves the length of `data` and stores it in size.
            let size := mload(data)

            // Stores `0x00` at `data`, effectively overwriting the length prefix (which is the first 32 bytes of the bytes array).
            // So the memory now looks like this:
            // Bytes [0..31] These 32 bytes are now all zeros. This effectively replaces the length field with zeros.
            // This avoids the need to explicitly create a new bytes array with an added 0x00 at the beginning.
            // => Avoid having to copy all the data again with abi.encodePacked(hex"00", data).

            // Why overwrite the length prefix?
            // The contract is preparing data for return, and the length prefix is not required in the returned raw data.
            // it wants to prepend a single zero byte (from the overwritten length slot) in front of the actual data.

            mstore(data, 0x00)

            // return(start, length)
            // returns a memory segment of size `length`, starting at `start`

            // `data` is a pointer to the original bytes array.

            // Why Offset by 31 (0x1F) Exactly?
            // If you return from data + 32 (i.e. using 32), you'd start at the very beginning of the actual data and lose the prepended 0x00.

            // By returning from data + 31, you are returning:
            //  => The last byte of the 32 bytes that were overwritten (which is guaranteed to be 0x00).
            //  => Followed immediately by all the actual data (starting at data + 32).
            // The returned memory block becomes:
            // [ 0x00 (from the zeroed length slot) | original data bytes ]
            // The length of the returned block is set to size + 1 so that it includes that prepended zero.

            // If you use a number less than 31 (say, 30 or 0x1E), then the starting pointer would include more than one byte of the zero block.
            // That means the returned block would contain extra zero bytes at the front, which is not what you want.
            // The goal is to include exactly one zero byte.
            // Since the length slot is 32 bytes long, starting 31 bytes in (i.e. offset by 0x1F) gives you just the last byte of that slot.

            // `size` is the original length of `data`.
            // +1 accounts for the 0x00 byte that was manually inserted.
            return(add(data, 0x1F), add(size, 1))
        }
    }
}
