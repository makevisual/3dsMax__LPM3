import os

def countlines(start, lines=0, header=True, begin_start=None):
    if header:
        print('{:>10} |{:>10} | {:<20}'.format('ADDED', 'TOTAL', 'FILE'))
        print('{:->11}|{:->11}|{:->20}'.format('', '', ''))

    for thing in os.listdir(start):
        thing = os.path.join(start, thing)
        if os.path.isfile(thing):
            if thing.endswith('.ms'):
                with open(thing, 'r') as f:
                    newlines = f.readlines()
                    newlines = len(newlines)
                    lines += newlines

                    if begin_start is not None:
                        reldir_of_thing = '.' + thing.replace(begin_start, '')
                    else:
                        reldir_of_thing = '.' + thing.replace(start, '')

                    print('{:>10} |{:>10} | {:<20}'.format(
                            newlines, lines, reldir_of_thing))

    for thing in os.listdir(start):
        thing = os.path.join(start, thing)
        if os.path.isdir(thing):
            lines = countlines(thing, lines, header=False, begin_start=start)

    return lines

#countlines(R"C:\Users\AaronDabelow\Documents\GitHub\3dsMax__LPM2\LPM_2.10\Release\Scripts\LPM")
#countlines(R"U:\Make_Tools\LPM2\LPM_2.10.3\Release\Scripts\LPM")
countlines(R"C:\Users\theon\OneDrive\Documents\GitHub\3dsMax__LPM2\LPM_2.9.2")
countlines(R"C:\Users\theon\OneDrive\Documents\GitHub\3dsMax__LPM2\LPM_2.10")