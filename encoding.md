
- [ASCII table](http://www.robelle.com/library/smugbook/ascii.html)
  - 32-127 for printable english char
  - 0-32 for non printable char (control char)
  - this occupies 7bits
- 8th bit is free (to fill up a byte) :
  - 128-255 were custom, everyone had their take on it : OEM (original equimement manufacturer) character like for the IBM PC
  - 128-255 were different for everyone, allowing for regional characters
  - they got codified in the ANSI standard and then called code pages
- so until then, 1 byte was 1 character... that was a long time ago. (and not true for asian codepages)

# Unicode

- a brave effort to create a single character set that included every reasonable writing system
- https://home.unicode.org/
- in unicode, information is stored on 16 bits (2 bytes) = 2\*\*16 -> 65,536
- 2 ways to store 2 bytes on disc ->  Unicode Byte Order Mark 
- the pb : too many zeroes

- In UTF-8, every code point from 0-127 is stored in a single byte. Only code points 128 and above are stored using 2, 3, in fact, up to 6 bytes.


- So far I’ve told you three ways of encoding Unicode. The traditional store-it-in-two-byte methods are called UCS-2 (because it has two bytes) or UTF-16 (because it has 16 bits), and you still have to figure out if it’s high-endian UCS-2 or low-endian UCS-2. And there’s the popular new UTF-8 standard which has the nice property of also working respectably if you have the happy coincidence of English text and braindead programs that are completely unaware that there is anything other than ASCII.

- If you have a string, in memory, in a file, or in an email message, you have to know what encoding it is in or you cannot interpret it or display it to users correctly.

- hence why stuff like this in http : Content-Type: text/plain; charset="UTF-8"

- how to know the encoding of a text? if not specified with a BOM (byte order mark)[https://en.wikipedia.org/wiki/Byte_order_mark], you can TRY to guess.

# exemples

- modify an omega file with accent in gitlab.
- save a file with special char and ascii chars. Save mutliple times using various encoding and watch the content with HxD
