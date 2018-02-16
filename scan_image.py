#!/usr/bin/python 
import pyinsane2
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--output_name", default="scansione.jpg", help="string to search into")
    parser.add_argument("-r", "--resolution", default="150", help="string to search into")
    args = parser.parse_args()
    output_name=args.output_name
    resolution=args.resolution 

    pyinsane2.init()

    try:
            devices = pyinsane2.get_devices()
            assert(len(devices) > 0)
            device = devices[0]
            print("I'm going to use the following scanner: %s" % (str(device)))

            pyinsane2.set_scanner_opt(device, 'resolution', [int(resolution)])

    # Beware: Some scanners have "Lineart" or "Gray" as default mode
    # better set the mode everytime
    #	pyinsane2.set_scanner_opt(device, 'mode', 'Gray')

    # Beware: by default, some scanners only scan part of the area
    # they could scan.
            pyinsane2.maximize_scan_area(device)

            scan_session = device.scan(multiple=False)
            try:
                    while True:
                            scan_session.scan.read()
            except EOFError:
                    pass
            image = scan_session.images[-1]
            image.save(output_name, "JPEG")
            print("Done")
    finally:
            pyinsane2.exit()

if __name__ == '__main__':
    main()
