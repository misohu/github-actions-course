import os
import sys

def main():
    try:
        name = os.getenv('INPUT_NAME', 'No name provided')
        print(f'Arg received {name}')

        print('Workdir:')
        for filename in os.listdir('.'):
            print(filename)

        with open('name.txt', 'w') as file:
            file.write(name)

        print(f'::set-output name=processed-name::{name}')

    except Exception as e:
        print(f'::error::{e}')
        sys.exit(1)

if __name__ == "__main__":
    main()