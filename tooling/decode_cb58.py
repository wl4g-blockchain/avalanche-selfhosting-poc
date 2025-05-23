import sys
import base58

def cb58_decode(cb58_str):
    decoded = base58.b58decode(cb58_str)
    data = decoded[:-4] # Remove checksum (tail 4 bytes)
    return data

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python decode_cb58.py <CB58_STRING>")
        sys.exit(1)
    
    cb58_str = sys.argv[1]
    try:
        decoded = cb58_decode(cb58_str)
        hex_str = "0x" + decoded.hex()
        print(hex_str)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
