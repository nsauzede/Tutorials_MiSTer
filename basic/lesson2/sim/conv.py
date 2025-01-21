#!/bin/python3

def intel_hex_to_raw(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if not line.startswith(':'):
                continue  # Skip invalid lines
            # Parse Intel HEX fields
            byte_count = int(line[1:3], 16)
            address = int(line[3:7], 16)  # Not used for raw output
            record_type = int(line[7:9], 16)
            data = line[9:9 + 2 * byte_count]
            checksum = int(line[9 + 2 * byte_count:9 + 2 * byte_count + 2], 16)
            
            if record_type == 0:  # Data record
                # Write data as raw HEX (one word per line)
                for i in range(0, len(data), 2):
                    outfile.write(f"{data[i:i+2]}\n")

if __name__ == "__main__":
    import sys
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    input_hex_file = arg1  # Replace with your Intel HEX file
    output_hex_file = arg2  # Replace with desired raw HEX output file
    intel_hex_to_raw(input_hex_file, output_hex_file)
    print(f"Converted {input_hex_file} to {output_hex_file}")
